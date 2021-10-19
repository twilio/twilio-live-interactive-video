//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

struct RaiseHandRequest: APIRequest {
    struct Parameters: Encodable {
        let userIdentity: String
        let streamName: String
        let handRaised: Bool
    }

    struct Response: Decodable {
        let sent: Bool
    }

    let path = "raise-hand"
    let parameters: Parameters
    let responseType = Response.self
    
    init(userIdentity: String, streamName: String, handRaised: Bool) {
        parameters = Parameters(userIdentity: userIdentity, streamName: streamName, handRaised: handRaised)
    }
}
