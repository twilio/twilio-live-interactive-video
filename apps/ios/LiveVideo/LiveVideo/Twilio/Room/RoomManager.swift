//
//  Copyright (C) 2020 Twilio, Inc.
//

import TwilioVideo

/// Configures the video room connection and uses notifications to broadcast state changes to multiple subscribers.
class RoomManager: NSObject {
    var localParticipant: LocalParticipantManager!
    private(set) var remoteParticipants: [RemoteParticipantManager] = []
    private let notificationCenter = NotificationCenter.default
    private var room: Room?

    func connect(roomName: String, accessToken: String) {
        let options = ConnectOptions(token: accessToken) { builder in
            builder.roomName = roomName
            builder.audioTracks = [self.localParticipant.micTrack].compactMap { $0 }
            builder.videoTracks = [self.localParticipant.cameraTrack].compactMap { $0 }
            builder.isDominantSpeakerEnabled = true
            builder.bandwidthProfileOptions = BandwidthProfileOptions(
                videoOptions: VideoBandwidthProfileOptions { builder in
                    builder.mode = .grid
                    builder.dominantSpeakerPriority = .high
                }
            )
            builder.preferredVideoCodecs = [Vp8Codec(simulcast: true)]
        }

        room = TwilioVideoSDK.connect(options: options, delegate: self)
    }

    func disconnect() {
        room?.disconnect()
        cleanUp()
        
        // Intentional disconnect and no error so object is nil
        notificationCenter.post(name: .roomDidDisconnectWithError, object: nil)
    }
    
    private func cleanUp() {
        room = nil
        localParticipant.participant = nil
        remoteParticipants.removeAll()
    }
    
    private func handleError(_ error: Error) {
        cleanUp()
        
        // For convenience send error as object instead of self
        notificationCenter.post(name: .roomDidDisconnectWithError, object: error)
    }
}

extension RoomManager: RoomDelegate {
    func roomDidConnect(room: Room) {
        localParticipant.participant = room.localParticipant
        remoteParticipants = room.remoteParticipants
            .filter { !$0.isVideoComposer } // Hide the video composer participant because it is not a human
            .map { RemoteParticipantManager(participant: $0) }
        notificationCenter.post(name: .roomDidConnect, object: self)
    }
    
    func roomDidFailToConnect(room: Room, error: Error) {
        handleError(error)
    }
    
    func roomDidDisconnect(room: Room, error: Error?) {
        guard let error = error else { return }
        
        handleError(error)
    }
    
    func participantDidConnect(room: Room, participant: RemoteParticipant) {
        // Hide the video composer participant because it is not a human. The video composer
        // participant may connect here after a temporary disconnect.
        guard !participant.isVideoComposer else { return }
        
        remoteParticipants.append(RemoteParticipantManager(participant: participant))

        // For convenience send participant as object instead of self
        notificationCenter.post(name: .remoteParticipantDidConnect, object: remoteParticipants.last)
    }
    
    func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
        guard let index = remoteParticipants.firstIndex(where: { $0.identity == participant.identity }) else { return }

        // For convenience send participant as object instead of self
        notificationCenter.post(name: .remoteParticipantDidDisconnect, object: remoteParticipants.remove(at: index))
    }

    func dominantSpeakerDidChange(room: Room, participant: RemoteParticipant?) {
        // Add dominant speaker state to participants so participants contain all
        // participant state. This is better for the UI.
        remoteParticipants.first { $0.isDominantSpeaker }?.isDominantSpeaker = false // Old speaker
        remoteParticipants.first { $0.identity == participant?.identity }?.isDominantSpeaker = true // New speaker
    }
}

private extension RemoteParticipant {
    var isVideoComposer: Bool {
        identity.hasPrefix("video-composer")
    }
}
