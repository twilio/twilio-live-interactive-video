//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

struct StreamConfig {
    enum Role: String, Identifiable {
        case host
        case speaker
        case viewer

        var id: String { rawValue }
    }

    let streamName: String
    let userIdentity: String
    let shouldRecord: Bool?
    var role: Role

    var hasUserDocument: Bool {
        switch role {
        case .host:
            return false
        case .speaker, .viewer:
            return true
        }
    }
}
