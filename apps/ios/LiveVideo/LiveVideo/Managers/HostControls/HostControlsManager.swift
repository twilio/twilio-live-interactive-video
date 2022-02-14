//
//  Copyright (C) 2022 Twilio, Inc.
//

import Foundation

class HostControlsManager: ObservableObject {
    private var roomManager: RoomManager!
    private var api: API!

    func configure(roomManager: RoomManager, api: API) {
        self.roomManager = roomManager
        self.api = api
    }
    
    func muteSpeaker(identity: String) {
        let message = RoomMessage(messageType: .mute, toParticipantIdentity: identity)
        roomManager.localParticipant.sendMessage(message)
    }

    func removeSpeaker(identity: String) {
        guard let roomName = roomManager.roomName else {
            return
        }
        
        let request = RemoveSpeakerRequest(roomName: roomName, userIdentity: identity)
        api.request(request)
    }
}
