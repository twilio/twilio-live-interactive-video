//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

enum LiveVideoError: Error {
    case backendError(message: String)
    case passcodeIncorrect
    case speakerMovedToViewersByHost
    case streamEndedByHost
    case syncClientConnectionFatalError
    case syncTokenExpired
}

extension LiveVideoError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .backendError(message): return message
        case .passcodeIncorrect: return "Passcode incorrect."
        case .speakerMovedToViewersByHost: return "Speaker moved to viewers by host."
        case .streamEndedByHost: return "Event ended by host."
        case .syncClientConnectionFatalError: return "Sync client connection fatal error."
        case .syncTokenExpired: return "Sync token expired."
        }
    }
}
