//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

struct DeleteStreamRequest: APIRequest {
    struct Parameters: Encodable {
        let streamName: String
    }

    struct Response: Decodable {
        let deleted: Bool
    }

    let path = "delete-stream"
    let parameters: Parameters
    let responseType = Response.self
    
    init(streamName: String) {
        parameters = Parameters(streamName: streamName)
    }
}
