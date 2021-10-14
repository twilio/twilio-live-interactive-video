//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

struct DeleteStreamRequest: APIRequest {
    struct Parameters: Encodable {
        let roomName: String
    }

    struct Response: Decodable {
        let deleted: Bool
    }

    let path = "delete-stream"
    let parameters: Parameters
    let responseType = Response.self
    
    init(roomName: String) {
        parameters = Parameters(roomName: roomName)
    }
}
