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
import Combine

class RoomManager: NSObject, ObservableObject {
    var localParticipant: LocalParticipant!
    var remoteParticipants: [RoomRemoteParticipant] = []
    private(set) var state: RoomState = .disconnected
    private let connectOptionsFactory = ConnectOptionsFactory()
    private let notificationCenter = NotificationCenter.default
    private var room: TwilioVideo.Room?

    func connect(roomName: String, accessToken: String, identity: String) {
        guard state == .disconnected else { fatalError("Connection already in progress.") }

        localParticipant.isCameraOn = true
//        localParticipant.isMicOn = true
        
        state = .connecting

        let options = self.connectOptionsFactory.makeConnectOptions(
            accessToken: accessToken,
            roomName: roomName,
            audioTracks: [self.localParticipant.micTrack].compactMap { $0 },
            videoTracks: [self.localParticipant.localCameraTrack].compactMap { $0 }
        )
        self.room = TwilioVideoSDK.connect(options: options, delegate: self)
    }

    func disconnect() {
        room?.disconnect()
    }
}

extension RoomManager: RoomDelegate {
    func roomDidConnect(room: TwilioVideo.Room) {
        localParticipant.participant = room.localParticipant
        remoteParticipants = room.remoteParticipants.map { RoomRemoteParticipant(participant: $0) }
        state = .connected
        notificationCenter.post(name: .roomDidConnect, object: self)
    }
    
    func roomDidFailToConnect(room: TwilioVideo.Room, error: Error) {
        state = .disconnected
        notificationCenter.post(name: .roomDidFailToConnect, object: error)
    }
    
    func roomDidDisconnect(room: TwilioVideo.Room, error: Error?) {
        localParticipant.participant = nil
        remoteParticipants.removeAll()
        state = .disconnected
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

    // TODO: Handle this in UI and speaker store
    func dominantSpeakerDidChange(room: TwilioVideo.Room, participant: TwilioVideo.RemoteParticipant?) {

    }
}
