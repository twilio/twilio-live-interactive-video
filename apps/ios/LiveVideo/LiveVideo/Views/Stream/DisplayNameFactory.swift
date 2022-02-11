//
//  Copyright (C) 2022 Twilio, Inc.
//

import Foundation

class DisplayNameFactory {
    func makeDisplayName(identity: String, isHost: Bool, isYou: Bool = false) -> String {
        "\(isYou ? "You" : identity)\(isHost ? " (Host)" : "")"
    }
}
