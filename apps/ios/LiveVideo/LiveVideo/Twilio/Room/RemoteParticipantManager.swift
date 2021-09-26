//
//  Copyright (C) 2020 Twilio, Inc.
//

import TwilioVideo

/// Determines remote participant state and uses notifications to broadcast state changes to multiple subscribers.
///
/// Also stores dominant speaker state received by the room so that participants contains all participant state.
/// This is better for the UI. See `isDominantSpeaker` and `dominantSpeakerStartTime`.
class RemoteParticipantManager: NSObject {
    var identity: String { participant.identity }
    var isMicOn: Bool {
        guard let track = participant.remoteAudioTracks.first else { return false }
        
        return track.isTrackSubscribed && track.isTrackEnabled
    }
    var cameraTrack: VideoTrack? {
        guard
            let publication = participant.remoteVideoTracks.first(where: { $0.trackName.contains(TrackName.camera) }),
            let track = publication.remoteTrack,
            track.isEnabled
        else {
            return nil
        }
        
        return track
    }
    var isDominantSpeaker = false {
        didSet {
            dominantSpeakerStartTime = Date()
            postChangeNotification()
        }
    }
    var dominantSpeakerStartTime: Date = .distantPast
    private let participant: RemoteParticipant
    private let notificationCenter = NotificationCenter.default
    
    init(participant: RemoteParticipant) {
        self.participant = participant
        super.init()
        participant.delegate = self
    }

    private func postChangeNotification() {
        notificationCenter.post(name: .remoteParticipantDidChange, object: self)
    }
}

extension RemoteParticipantManager: RemoteParticipantDelegate {
    func didSubscribeToVideoTrack(
        videoTrack: RemoteVideoTrack,
        publication: RemoteVideoTrackPublication,
        participant: RemoteParticipant
    ) {
        postChangeNotification()
    }
    
    func didUnsubscribeFromVideoTrack(
        videoTrack: RemoteVideoTrack,
        publication: RemoteVideoTrackPublication,
        participant: RemoteParticipant
    ) {
        postChangeNotification()
    }

    func remoteParticipantDidEnableVideoTrack(
        participant: RemoteParticipant,
        publication: RemoteVideoTrackPublication
    ) {
        postChangeNotification()
    }
    
    func remoteParticipantDidDisableVideoTrack(
        participant: RemoteParticipant,
        publication: RemoteVideoTrackPublication
    ) {
        postChangeNotification()
    }

    func didSubscribeToAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: RemoteParticipant
    ) {
        postChangeNotification()
    }
    
    func didUnsubscribeFromAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: RemoteParticipant
    ) {
        postChangeNotification()
    }

    func remoteParticipantDidEnableAudioTrack(
        participant: RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        postChangeNotification()
    }
    
    func remoteParticipantDidDisableAudioTrack(
        participant: RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        postChangeNotification()
    }
}
