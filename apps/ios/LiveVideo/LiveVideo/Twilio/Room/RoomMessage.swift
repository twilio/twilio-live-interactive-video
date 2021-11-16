//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

struct RoomMessage: Codable {
    enum MessageType: String, Codable {
        case mute
    }
    
    let messageType: MessageType
    let toParticipantIdentity: String
}
