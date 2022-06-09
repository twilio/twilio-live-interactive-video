//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

struct CreateOrJoinStreamRequest: APIRequest {
    struct Parameters: Encodable {
        let userIdentity: String
        let streamName: String
        let recordStream: Bool?
    }

    struct Response: Decodable {
        let token: String
    }

    let path: String
    let parameters: Parameters
    let responseType = Response.self
    
    init(userIdentity: String, streamName: String, role: StreamConfig.Role, recordStream: Bool?) {
        parameters = Parameters(userIdentity: userIdentity, streamName: streamName, recordStream: recordStream)
        path = role.path
    }
}

private extension StreamConfig.Role {
    var path: String {
        switch self {
        case .host: return "create-stream"
        case .speaker: return "join-stream-as-speaker"
        case .viewer: return "join-stream-as-viewer"
        }
    }
}
