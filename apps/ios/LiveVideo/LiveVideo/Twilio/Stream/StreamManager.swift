//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import TwilioPlayer

class StreamManager: ObservableObject {
    enum State {
        case disconnected
        case connecting
        case connected
    }
    
    @Published var state = State.disconnected
    @Published var player: Player?
    @Published var showError = false
    @Published var error: Error? {
        didSet {
            showError = error != nil
        }
    }
    private var api: API?
    private var playerManager: PlayerManager?
    private var roomManager: RoomManager!
    private var subscriptions = Set<AnyCancellable>()

    func configure(roomManager: RoomManager, playerManager: PlayerManager, api: API) {
        self.roomManager = roomManager
        self.playerManager = playerManager
        self.api = api
        
        roomManager.roomConnectPublisher
            .sink { [weak self] in self?.state = .connected }
            .store(in: &subscriptions)

        roomManager.roomDisconnectPublisher
            .sink { [weak self] error in
                guard let error = error else { return }
                
                self?.handleError(error)
            }
            .store(in: &subscriptions)
        
        roomManager.localParticipant.errorPublisher
            .sink { [weak self] error in self?.handleError(error) }
            .store(in: &subscriptions)

        playerManager.delegate = self
    }

    func connect(config: StreamConfig) {
        guard let api = api else { return }
        
        state = .connecting
 
        switch config.role {
        case .host, .speaker:
            let request = TokenRequest(userIdentity: config.userIdentity, roomName: config.streamName)
            
            api.request(request) { [weak self] result in
                switch result {
                case let .success(response):
                    self?.roomManager.localParticipant.isCameraOn = true
                    self?.roomManager.localParticipant.isMicOn = true
                    self?.roomManager.connect(roomName: config.streamName, accessToken: response.token)
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
        state = .disconnected
    }
    
    private func handleError(_ error: Error) {
        disconnect()
        self.error = error
    }
}

extension StreamManager: PlayerManagerDelegate {
    func playerManagerDidConnect(_ playerManager: PlayerManager) {
        player = playerManager.player
        state = .connected
    }
    
    func playerManager(_ playerManager: PlayerManager, didDisconnectWithError error: Error) {
        handleError(error)
    }
}
