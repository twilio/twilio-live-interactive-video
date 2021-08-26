//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import SwiftyUserDefaults

class AuthManager: ObservableObject {
    @Published var isSignedOut = Defaults.userIdentity.isEmpty
    @Published var userIdentity = Defaults.userIdentity

    func signIn(userIdentity: String) {
        Defaults.userIdentity = userIdentity
        self.userIdentity = userIdentity
        isSignedOut = false
    }

    func signOut() {
        isSignedOut = true
        Defaults.userIdentity = ""
        userIdentity = ""
    }
}
