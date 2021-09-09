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
    private let notificationCenter = NotificationCenter.default
    
    init(api: API?, playerManager: PlayerManager?) {
        self.api = api
        self.playerManager = playerManager
        playerManager?.delegate = self
        
        notificationCenter.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    func connect(config: StreamConfig) {
        guard let api = api else { return }
        
        isLoading = true
        let request = StreamTokenRequest(userIdentity: config.userIdentity, roomName: config.streamName)
        
        api.request(request) { [weak self] result in
            switch result {
            case let .success(response):
                self?.playerManager?.configure(accessToken: response.token)
                self?.playerManager?.connect()
            case let .failure(error):
                self?.handleError(error)
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

    @objc private func appDidEnterBackground() {
        player = nil // Stop rendering video to avoid unnecessary processing
    }

    @objc private func appWillEnterForeground() {
        guard let playerManager = playerManager, playerManager.isPlaying else { return }

        player = playerManager.player // Render video when the app is in the foreground
    }
}

extension StreamManager: PlayerManagerDelegate {
    func playerManagerDidStartPlaying(_ playerManager: PlayerManager) {
        switch UIApplication.shared.applicationState {
        case .active, .inactive:
            player = playerManager.player // Render video when the app is in the foreground
        case .background:
            break
        @unknown default:
            break
        }

        isLoading = false
    }
    
    func playerManager(_ playerManager: PlayerManager, didDisconnectWithError error: Error) {
        handleError(error)
    }
}
