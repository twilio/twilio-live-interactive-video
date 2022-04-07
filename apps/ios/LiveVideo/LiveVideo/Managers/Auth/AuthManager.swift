//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import KeychainAccess

class AuthManager: ObservableObject {
    @Published var isSignedOut = true
    @Published var userIdentity = ""
    private let keychain = Keychain()
    private let userIdentityKey = "UserIdentity" // Store user identity in keychain because it is PII
    private let passcodeKey = "Passcode" // Store passcode in keychain because it is secret
    private var api: API!
    private var appSettingsManager: AppSettingsManager!

    func configure(api: API, appSettingsManager: AppSettingsManager) {
        self.api = api
        self.appSettingsManager = appSettingsManager

        if let userIdentity = keychain[userIdentityKey], let passcode = keychain[passcodeKey] {
            isSignedOut = false
            self.userIdentity = userIdentity
            try? configureAPI(passcode: passcode)
        }
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
        appSettingsManager.reset()
    }
    
    private func configureAPI(passcode: String) throws {
        let passcodeComponents = try PasscodeComponents(string: passcode)
        let backendURL = "https://twilio-live-interactive-video-" + passcodeComponents.appID + "-" + passcodeComponents.serverlessID + "-dev." + appSettingsManager.environment.domain
        api.configure(backendURL: backendURL, passcode: passcodeComponents.passcode)
    }
}
