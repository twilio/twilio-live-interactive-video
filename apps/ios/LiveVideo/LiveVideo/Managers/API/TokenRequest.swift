//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

struct TokenRequest: APIRequest {
    struct Parameters: Encodable {
        let userIdentity: String
        let roomName: String
    }

    struct Response: Decodable {
        let token: String
        let roomSid: String
    }

    let path = "token"
    let parameters: Parameters
    let responseType = Response.self
    
    init(userIdentity: String, roomName: String) {
        parameters = Parameters(userIdentity: userIdentity, roomName: roomName)
    }
}
