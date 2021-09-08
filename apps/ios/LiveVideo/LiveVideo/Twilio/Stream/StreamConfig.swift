//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

struct StreamConfig {
    enum Role {
        case host
        case speaker
        case viewer
    }
    
    let streamName: String
    let userIdentity: String
    let role: Role
}
