//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

struct TokenRequest: APIRequest {
    struct Parameters: Encodable {
        let userIdentity: String
        let eventName: String
    }

    struct Response: Decodable {
        struct SyncObjectNames: Decodable {
            let raisedHandsMap: String
            let viewerDocument: String?
        }
        
        let token: String
        let syncObjectNames: SyncObjectNames
    }

    let path: String
    let parameters: Parameters
    let responseType = Response.self
    
    init(userIdentity: String, eventName: String, role: StreamConfig.Role) {
        parameters = Parameters(userIdentity: userIdentity, eventName: eventName)
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
