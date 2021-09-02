//
//  Copyright (C) 2021 Twilio, Inc.
//

import TwilioPlayer

class StreamManager: ObservableObject {
    @Published var isLoading = false
    @Published var player: Player?
    @Published var showError = false
    @Published var error: Error? {
        didSet {
            showError = error != nil
        }
    }
    private let api: API?
    private let playerManager: PlayerManager?
    
    init(api: API?, playerManager: PlayerManager?) {
        self.api = api
        self.playerManager = playerManager
        playerManager?.delegate = self
    }

    func connect(config: StreamConfig) {
        guard let api = api else { return }
        
        isLoading = true
        let request = StreamTokenRequest(userIdentity: config.userIdentity, roomName: config.roomName)
        
        api.request(request) { [weak self] result in
            switch result {
            case let .success(response):
                self?.playerManager?.configure(accessToken: response.token)
                self?.playerManager?.connect()
            case let .failure(error):
                self?.error = error
            }
        }
    }
    
    func disconnect() {
        playerManager?.disconnect()
        player = nil
        isLoading = false
    }
    
    private func handleError(_ error: Error) {
        disconnect()
        self.error = error
    }
}

extension StreamManager: PlayerManagerDelegate {
    func playerManagerDidConnect(_ playerManager: PlayerManager) {
        player = playerManager.player
        isLoading = false
    }
    
    func playerManager(_ playerManager: PlayerManager, didDisconnectWithError error: Error) {
        handleError(error)
    }
}
