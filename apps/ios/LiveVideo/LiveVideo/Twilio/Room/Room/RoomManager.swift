//
//  Copyright (C) 2020 Twilio, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import TwilioVideo

class RoomManager: NSObject, ObservableObject {
    var localParticipant: LocalParticipant!
    var remoteParticipants: [RoomRemoteParticipant] = []
    private let notificationCenter = NotificationCenter.default
    private var room: Room?

    func connect(roomName: String, accessToken: String, identity: String) {
        localParticipant.isCameraOn = true
//        localParticipant.isMicOn = true

        let options = ConnectOptions(token: accessToken) { builder in
            builder.roomName = roomName
            builder.audioTracks = [self.localParticipant.micTrack].compactMap { $0 }
            builder.videoTracks = [self.localParticipant.localCameraTrack].compactMap { $0 }
            builder.isDominantSpeakerEnabled = true
            builder.bandwidthProfileOptions = BandwidthProfileOptions(
                videoOptions: VideoBandwidthProfileOptions { builder in
                    builder.mode = .grid
                }
            )
            builder.preferredVideoCodecs = [Vp8Codec(simulcast: true)]
            builder.encodingParameters = EncodingParameters(audioBitrate: 16, videoBitrate: 0)
        }

        self.room = TwilioVideoSDK.connect(options: options, delegate: self)
    }

    func disconnect() {
        room?.disconnect()
        room = nil
    }
}

extension RoomManager: RoomDelegate {
    func roomDidConnect(room: TwilioVideo.Room) {
        localParticipant.participant = room.localParticipant
        remoteParticipants = room.remoteParticipants.map { RoomRemoteParticipant(participant: $0) }
        notificationCenter.post(name: .roomDidConnect, object: self)
    }
    
    func roomDidFailToConnect(room: TwilioVideo.Room, error: Error) {
        notificationCenter.post(name: .roomDidFailToConnect, object: error)
    }
    
    func roomDidDisconnect(room: TwilioVideo.Room, error: Error?) {
        localParticipant.participant = nil
        remoteParticipants.removeAll()
        notificationCenter.post(name: .roomDidDisconnect, object: error)
    }
    
    func participantDidConnect(room: TwilioVideo.Room, participant: TwilioVideo.RemoteParticipant) {
        remoteParticipants.append(RoomRemoteParticipant(participant: participant))
        notificationCenter.post(name: .remoteParticipantDidConnect, object: remoteParticipants.last)
    }
    
    func participantDidDisconnect(room: TwilioVideo.Room, participant: TwilioVideo.RemoteParticipant) {
        guard let index = remoteParticipants.firstIndex(where: { $0.identity == participant.identity }) else { return }

        notificationCenter.post(name: .remoteParticipantDidDisconnect, object: remoteParticipants.remove(at: index))
    }

    func dominantSpeakerDidChange(room: TwilioVideo.Room, participant: TwilioVideo.RemoteParticipant?) {
        guard let new = remoteParticipants.first(where: { $0.identity == participant?.identity }) else { return }

        let old = remoteParticipants.first(where: { $0.isDominantSpeaker })
        old?.isDominantSpeaker = false
        new.isDominantSpeaker = true
    }
}
