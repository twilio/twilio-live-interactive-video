//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

struct SendSpeakerInviteRequest: APIRequest {
    struct Parameters: Encodable {
        let userIdentity: String
        let roomName: String
        let roomSid: String
    }

    struct Response: Decodable {
        let success: Bool
    }

    let path = "send-speaker-invite"
    let parameters: Parameters
    let responseType = Response.self
    
    init(userIdentity: String, roomName: String, roomSID: String) {
        parameters = Parameters(userIdentity: userIdentity, roomName: roomName, roomSid: roomSID)
    }
}
