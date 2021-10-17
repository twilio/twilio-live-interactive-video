//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import TwilioPlayer

/// Connects to a stream and can reconnect as speaker or viewer to change role.
///
/// Internally coordinates `RoomManager`, `PlayerManager`, and `SyncManager` connections.
class StreamManager: ObservableObject {
    enum State {
        case disconnected
        case connecting
        case connected
        case changingRole
    }

    let errorPublisher = PassthroughSubject<Error, Never>()
    @Published var state = State.disconnected
    @Published var player: Player?
    var config: StreamConfig!
    private var roomManager: RoomManager!
    private var playerManager: PlayerManager!
    private var syncManager: SyncManager!
    private var api: API!
    private var subscriptions = Set<AnyCancellable>()

    func configure(
        roomManager: RoomManager,
        playerManager: PlayerManager,
        syncManager: SyncManager,
        api: API
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
        guard api != nil else {
            return /// When not configured do nothing so `PreviewProvider` doesn't crash.
        }

        state = .connecting
        privateConnect()
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
    
    /// Change role from viewer to speaker or speaker to viewer.
    ///
    /// - Note: The user that created the stream is the host. There is only one host and the host cannot change. When the host leaves the stream ends.
    func changeRole(to role: StreamConfig.Role) {
        guard role != .host && config.role != .host else {
            fatalError("The host cannot change.")
        }
        
        disconnect()
        config.role = role
        state = .changingRole
        privateConnect()
    }
        
    private func privateConnect() {
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
