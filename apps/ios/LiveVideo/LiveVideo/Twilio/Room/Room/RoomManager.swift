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

class RoomManager: NSObject, TwilioVideo.RoomDelegate, ObservableObject {
    enum Update {
        case didStartConnecting
        case didConnect
        case didFailToConnect(error: Error)
        case didDisconnect(error: Error?)
    }

    var localParticipant: LocalParticipant!
    @Published var remoteParticipants: [RemoteParticipant] = []
    var speakerStore: SpeakerStore!
    private(set) var state: RoomState = .disconnected
    private let connectOptionsFactory = ConnectOptionsFactory()
    private let notificationCenter = NotificationCenter.default
    private var room: TwilioVideo.Room?

    func connect(roomName: String, accessToken: String, identity: String) {
        guard state == .disconnected else { fatalError("Connection already in progress.") }

        localParticipant = LocalParticipant(identity: identity)
        localParticipant.isCameraOn = true
//        localParticipant.isMicOn = true
        
        state = .connecting
        post(.didStartConnecting)

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
    
    private func post(_ update: Update) {
        notificationCenter.post(name: .roomUpdate, object: self, payload: update)
    }

    func roomDidConnect(room: TwilioVideo.Room) {
        localParticipant.participant = room.localParticipant
        remoteParticipants = room.remoteParticipants.map {
            RemoteParticipant(participant: $0)
        }
        room.remoteParticipants.forEach { speakerStore.addRemoteParticipant($0) }
        state = .connected
        post(.didConnect)
    }
    
    func roomDidFailToConnect(room: TwilioVideo.Room, error: Error) {
        state = .disconnected
        post(.didFailToConnect(error: error))
    }
    
    func roomDidDisconnect(room: TwilioVideo.Room, error: Error?) {
        localParticipant.participant = nil
        remoteParticipants.removeAll()
        speakerStore.removeAll()
        state = .disconnected
        post(.didDisconnect(error: error))
    }
    
    func participantDidConnect(room: TwilioVideo.Room, participant: TwilioVideo.RemoteParticipant) {
        remoteParticipants.append(RemoteParticipant(participant: participant))
        speakerStore.addRemoteParticipant(participant)
    }
    
    func participantDidDisconnect(room: TwilioVideo.Room, participant: TwilioVideo.RemoteParticipant) {
        guard let index = remoteParticipants.firstIndex(where: { $0.identity == participant.identity }) else { return }
        
        remoteParticipants.remove(at: index)
        speakerStore.removeRemoteParticipant(participant)
    }
    
    func dominantSpeakerDidChange(room: TwilioVideo.Room, participant: TwilioVideo.RemoteParticipant?) {
        guard let new = remoteParticipants.first(where: { $0.identity == participant?.identity }) else { return }

        let old = remoteParticipants.first(where: { $0.isDominantSpeaker })
        old?.isDominantSpeaker = false
        new.isDominantSpeaker = true
//        post(.didUpdateParticipants(participants: [old, new].compactMap { $0 }))
    }
}
