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
        case changingRole
    }

    @Published var state = State.disconnected
    @Published var player: Player?
    let errorPublisher = PassthroughSubject<Error, Never>()
    var config: StreamConfig!
    private var api: API!
    private var playerManager: PlayerManager!
    private var roomManager: RoomManager!
    private var syncManager: SyncManager!
    private var subscriptions = Set<AnyCancellable>()

    func configure(
        roomManager: RoomManager,
        playerManager: PlayerManager,
        api: API,
        syncManager: SyncManager
    ) {
        self.roomManager = roomManager
        self.playerManager = playerManager
        self.syncManager = syncManager
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

        syncManager.errorPublisher
            .sink { [weak self] error in self?.handleError(error) }
            .store(in: &subscriptions)

        playerManager.delegate = self
    }
    
    func connect() {
        guard api != nil else { return } // TODO: Explain more

        state = .connecting
        internalConnect()
    }
    
    func disconnect() {
        roomManager.disconnect()
        playerManager.disconnect()
        syncManager.disconnect()
        player = nil
        state = .disconnected
        
        if config.role == .host {
            let request = DeleteStreamRequest(streamName: config.streamName)
            api.request(request)
        }
    }
    
    func moveToSpeakers() {
        disconnect()
        config.role = .speaker
        state = .changingRole
        internalConnect()
    }

    func moveToViewers() {
        disconnect()
        config.role = .viewer
        state = .changingRole
        internalConnect()
    }
    
    private func internalConnect() {
        let request = CreateOrJoinStreamRequest(
            userIdentity: config.userIdentity,
            streamName: config.streamName,
            role: config.role
        )
        
        api.request(request) { [weak self] result in
            switch result {
            case let .success(response):
                self?.syncManager.connect(
                    token: response.token,
                    raisedHandsMapName: response.syncObjectNames.raisedHandsMap,
                    viewerDocumentName: response.syncObjectNames.viewerDocument
                ) { error in
                    guard let config = self?.config else {
                        return
                    }
                    
                    if let error = error {
                        self?.handleError(error)
                        return
                    }

                    switch config.role {
                    case .host, .speaker:
                        self?.roomManager.localParticipant.isCameraOn = true // TODO: Move and turn off on disconnect
                        self?.roomManager.localParticipant.isMicOn = true
                        self?.roomManager.connect(roomName: config.streamName, accessToken: response.token)
                    case .viewer:
                        self?.playerManager.connect(accessToken: response.token)
                    }
                }
            case let .failure(error):
                self?.handleError(error)
            }
        }
    }
    
    private func handleError(_ error: Error) {
        disconnect()
        errorPublisher.send(error)
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
