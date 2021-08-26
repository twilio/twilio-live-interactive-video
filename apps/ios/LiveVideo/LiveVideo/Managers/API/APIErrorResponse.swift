//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

struct APIErrorResponse: Decodable {
    struct Error: Decodable {
        let message: String
        let explanation: String
    }
    
    let error: Error
}
