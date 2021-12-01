//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

struct VerifyPasscodeRequest: APIRequest {
    struct Parameters: Encodable {
        // The backend verifies the passcode in the request header so no parameters needed
    }

    struct Response: Decodable {
        let verified: Bool
    }

    let path = "verify-passcode"
    let parameters = Parameters()
    let responseType = Response.self
}
