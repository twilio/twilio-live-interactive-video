//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import KeychainAccess

class AuthManager: ObservableObject {
    @Published var isSignedOut = true
    @Published var userIdentity = ""
    private let keychain = Keychain()
    private let userIdentityKey = "UserIdentity"
    private let passcodeKey = "Passcode"
    private var api: API!

    init() {
        guard let userIdentity = keychain[userIdentityKey], let passcode = keychain[passcodeKey] else {
            return
        }
        
        isSignedOut = false
        self.userIdentity = userIdentity
        try? configureAPI(passcode: passcode)
    }

    func configure(api: API) {
        self.api = api
    }
    
    func signIn(userIdentity: String, passcode: String, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try configureAPI(passcode: passcode)
        } catch {
            completion(.failure(error))
            return
        }
        
        api.request(VerifyPasscodeRequest()) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success:
                self.keychain[self.userIdentityKey] = userIdentity
                self.keychain[self.passcodeKey] = passcode
                self.userIdentity = userIdentity
                self.isSignedOut = false
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func signOut() {
        isSignedOut = true
        userIdentity = ""
        try? keychain.removeAll()
    }
    
    private func configureAPI(passcode: String) throws {
        let passcodeComponents = try PasscodeComponents(string: passcode)
        let backendURL = "https://twilio-live-interactive-video-" + passcodeComponents.appID + passcodeComponents.serverlessID + "-dev.twil.io"
        api.configure(backendURL: backendURL, passcode: passcodeComponents.passcode)
    }
}
