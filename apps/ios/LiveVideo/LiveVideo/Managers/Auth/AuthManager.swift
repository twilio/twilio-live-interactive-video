//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import Foundation
import KeychainAccess

/// Store user identity in passcode because it is PII. Store passcode in keychain because it is a secret.
class AuthManager: ObservableObject {
    @Published var isSignedOut = true
    @Published var userIdentity = ""
    private(set) var passcode = ""
    private let keychain = Keychain()
    private var api: API!

    init() {
        if let passcode = keychain["Passcode"], let userIdentity = keychain["UserIdentity"] {
            isSignedOut = false
            self.passcode = passcode
            self.userIdentity = userIdentity
            try? configureAPI(passcode: passcode)
        }
    }

    func configure(api: API) {
        self.api = api
    }
    
    func signIn(userIdentity: String, passcode: String, completion: @escaping (Error?) -> Void) {
        do {
            try configureAPI(passcode: passcode)
        } catch {
            completion(error)
            return
        }
        
        api.request(VerifyPasscodeRequest()) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success:
                self.keychain["UserIdentity"] = userIdentity
                self.keychain["Passcode"] = passcode
                self.userIdentity = userIdentity
                self.passcode = passcode
                self.isSignedOut = false
                completion(nil)
            case let .failure(error):
                completion(error)
            }
        }
    }

    func signOut() {
        isSignedOut = true
        keychain["UserIdentity"] = nil
        keychain["Passcode"] = nil
        passcode = ""
        userIdentity = ""
    }
    
    private func configureAPI(passcode: String) throws {
        let passcodeComponents = try PasscodeComponents(string: passcode)
        
        var appID: String {
            guard let appID = passcodeComponents.appID else { return "" }
            
            return "\(appID)-"
        }
        
        api.backendURL = "https://twilio-live-interactive-video-\(appID)\(passcodeComponents.serverlessID)-dev.twil.io"
    }
}
