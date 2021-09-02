//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

struct StreamTokenRequest: APIRequest {
    struct Parameters: Encodable {
        let userIdentity: String
        let roomName: String
    }

    struct Response: Decodable {
        let token: String
    }

    let path = "stream-token"
    let parameters: Parameters
    let responseType = Response.self
    
    init(userIdentity: String, roomName: String) {
        parameters = Parameters(userIdentity: userIdentity, roomName: roomName)
    }
}
