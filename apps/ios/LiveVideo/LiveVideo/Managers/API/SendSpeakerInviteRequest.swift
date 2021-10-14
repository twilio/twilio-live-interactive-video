//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

struct SendSpeakerInviteRequest: APIRequest {
    struct Parameters: Encodable {
        let userIdentity: String
        let roomSid: String
    }

    // TODO: null response?
    struct Response: Decodable {
        let success: Bool
    }

    let path = "send-speaker-invite"
    let parameters: Parameters
    let responseType = Response.self
    
    init(userIdentity: String, roomSID: String) {
        parameters = Parameters(userIdentity: userIdentity, roomSid: roomSID)
    }
}
