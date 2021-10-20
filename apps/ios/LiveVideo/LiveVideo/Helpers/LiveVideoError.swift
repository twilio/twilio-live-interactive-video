//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

enum LiveVideoError: Error {
    case backendError(message: String)
    case streamEndedByHost
    case syncClientConnectionFatalError
    case syncTokenExpired
}

extension LiveVideoError {
    var isStreamEndedByHostError: Bool {
        if case .streamEndedByHost = self { return true }
        return false
    }
}

extension LiveVideoError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .backendError(message): return message
        case .streamEndedByHost: return "Event ended by host."
        case .syncClientConnectionFatalError: return "Sync client connection fatal error."
        case .syncTokenExpired: return "Sync token expired."
        }
    }
}
