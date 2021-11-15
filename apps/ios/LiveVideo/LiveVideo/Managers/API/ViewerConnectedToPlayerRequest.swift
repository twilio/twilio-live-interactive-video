//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

struct ViewerConnectedToPlayerRequest: APIRequest {
    struct Parameters: Encodable {
        let userIdentity: String
        let streamName: String
    }

    struct Response: Decodable {
        let success: Bool
    }

    let path = "viewer-connected-to-player"
    let parameters: Parameters
    let responseType = Response.self
    
    init(userIdentity: String, streamName: String) {
        parameters = Parameters(userIdentity: userIdentity, streamName: streamName)
    }
}
