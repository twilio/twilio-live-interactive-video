//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
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
    var roomManager: RoomManager!
    private let api: API?
    private let playerManager: PlayerManager?
    private let notificationCenter = NotificationCenter.default
    private var subscriptions = Set<AnyCancellable>()

    init(api: API?, playerManager: PlayerManager?) {
        self.api = api
        self.playerManager = playerManager
        playerManager?.delegate = self
        
        notificationCenter.publisher(for: .roomDidConnect)
            .sink { [weak self] _ in self?.isLoading = false }
            .store(in: &subscriptions)

        notificationCenter.publisher(for: .roomDidDisconnectWithError)
            .map { $0.object as? Error }
            .sink { [weak self] error in
                guard let error = error else { return }
                
                self?.handleError(error)
            }
            .store(in: &subscriptions)
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
