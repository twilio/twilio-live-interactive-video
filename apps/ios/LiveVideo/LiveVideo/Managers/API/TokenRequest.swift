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
        struct SyncObjectNames: Decodable {
            let speakersMap: String
            let raisedHandsMap: String
            let viewerDocument: String
        }
        
        let token: String
        let syncObjectNames: SyncObjectNames
    }

    let path: String
    let parameters: Parameters
    let responseType = Response.self
    
    init(userIdentity: String, roomName: String, role: StreamConfig.Role) {
        parameters = Parameters(userIdentity: userIdentity, roomName: roomName)
        path = role.path
    }
}

private extension StreamConfig.Role {
    var path: String {
        switch self {
        case .host: return "token"
        case .speaker: return "token"
        case .viewer: return "stream-token"
        }
    }
}
