//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

struct VerifyPasscodeRequest: APIRequest {
    struct Parameters: Encodable {
        
    }

    struct Response: Decodable {
        let verified: Bool
    }

    let path = "verify-passcode"
    let parameters: Parameters
    let responseType = Response.self
    
    init() {
        parameters = Parameters()
    }
}
