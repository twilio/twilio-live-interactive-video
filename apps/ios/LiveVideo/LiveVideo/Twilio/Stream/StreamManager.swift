//
//  Copyright (C) 2021 Twilio, Inc.
//

import TwilioPlayer
import TwilioVideo

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
    var roomManager: RoomManager
    private let playerManager: PlayerManager?
    private let notificationCenter = NotificationCenter.default
    
    init(api: API?, roomManager: RoomManager, playerManager: PlayerManager?) {
        self.api = api
        self.roomManager = roomManager
        self.playerManager = playerManager
        notificationCenter.addObserver(self, selector: #selector(handleRoomUpdate(_:)), name: .roomUpdate, object: roomManager)
        playerManager?.delegate = self
    }

    func connect(config: StreamConfig) {
        guard let api = api else { return }
        
        isLoading = true
 
        switch config.role {
        case .host, .speaker:
            let request = TokenRequest(userIdentity: config.userIdentity, roomName: config.streamName)
            
            api.request(request) { [weak self] result in
                switch result {
                case let .success(response):
                    self?.roomManager.connect(roomName: config.streamName, accessToken: response.token, identity: config.userIdentity)
                case let .failure(error):
                    self?.handleError(error)
                }
            }
        case .viewer:
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
    }
    
    func disconnect() {
        roomManager.disconnect()
        playerManager?.disconnect()
        player = nil
        isLoading = false
    }
    
    private func handleError(_ error: Error) {
        disconnect()
        self.error = error
    }

    @objc private func handleRoomUpdate(_ notification: Notification) {
        guard let payload = notification.payload as? RoomManager.Update else { return }
        
        switch payload {
        case .didStartConnecting:
            break
        case .didConnect:
            isLoading = false
        case let .didFailToConnect(error):
            handleError(error)
        case let .didDisconnect(error):
            if let error = error {
                handleError(error)
            }
        }
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
