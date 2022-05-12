//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import TwilioLivePlayer

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
    private var chatManager: ChatManager!
    private var api: API!
    private var appSettingsManager: AppSettingsManager!
    private var accessToken: String?
    private var roomSID: String?
    private var subscriptions = Set<AnyCancellable>()

    func configure(
        roomManager: RoomManager,
        playerManager: PlayerManager,
        syncManager: SyncManager,
        api: API,
        appSettingsManager: AppSettingsManager,
        chatManager: ChatManager
    ) {
        self.roomManager = roomManager
        self.playerManager = playerManager
        self.syncManager = syncManager
        self.api = api
        self.appSettingsManager = appSettingsManager
        self.chatManager = chatManager
        
        roomManager.roomConnectPublisher
            .sink { [weak self] in
                self?.state = .connected
                self?.connectChat() /// Chat is not essential so connect it separately
            }
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

        /// Set environment variable used by `TwilioVideo` and `TwilioLivePlayer`. This is only used by Twilio employees for internal testing.
        setenv("TWILIO_ENVIRONMENT", appSettingsManager.environment.videoEnvironment, 1)

        fetchAccessToken()
    }
    
    func disconnect() {
        roomManager.disconnect()
        playerManager.disconnect()
        syncManager.disconnect()
        chatManager.disconnect()
        player = nil
        state = .disconnected
        
        if config.role == .host {
            let request = DeleteStreamRequest(streamName: config.streamName)
            api.request(request)
        }
    }
    
    /// Change role from viewer to speaker or speaker to viewer.
    ///
    /// - Note: The user that created the stream is the host. There is only one host and the host cannot change. When the host leaves the stream ends for all users.
    func changeRole(to role: StreamConfig.Role) {
        guard role != .host && config.role != .host else {
            fatalError("The host cannot change.")
        }
        
        roomManager.disconnect()
        playerManager.disconnect()
        player = nil
        config.role = role
        state = .changingRole
        fetchAccessToken()
    }

    private func fetchAccessToken() {
        let request = CreateOrJoinStreamRequest(
            userIdentity: config.userIdentity,
            streamName: config.streamName,
            role: config.role
        )
        
        api.request(request) { [weak self] result in
            switch result {
            case let .success(response):
                self?.accessToken = response.token
                self?.roomSID = response.roomSid
                
                let objectNames = SyncManager.ObjectNames(
                    speakersMap: response.syncObjectNames.speakersMap,
                    viewersMap: response.syncObjectNames.viewersMap,
                    raisedHandsMap: response.syncObjectNames.raisedHandsMap,
                    userDocument: response.syncObjectNames.userDocument
                )
                
                self?.connectSync(accessToken: response.token, objectNames: objectNames)
            case let .failure(error):
                self?.handleError(error)
            }
        }
    }
    
    private func connectSync(accessToken: String, objectNames: SyncManager.ObjectNames) {
        guard !syncManager.isConnected else {
            connectRoomOrPlayer(accessToken: accessToken)
            return
        }

        syncManager.connect(token: accessToken, objectNames: objectNames) { [weak self] error in
            if let error = error {
                self?.handleError(error)
                return
            }

            self?.connectRoomOrPlayer(accessToken: accessToken)
        }
    }
    
    private func connectRoomOrPlayer(accessToken: String) {
        switch config.role {
        case .host, .speaker:
            roomManager.connect(roomName: config.streamName, accessToken: accessToken)
        case .viewer:
            playerManager.connect(accessToken: accessToken)
        }
    }
    
    private func connectChat() {
        guard !chatManager.isConnected, let accessToken = accessToken, let roomSID = roomSID else {
            return
        }
        
        chatManager.connect(accessToken: accessToken, conversationName: roomSID)
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
        
        let request = ViewerConnectedToPlayerRequest(userIdentity: config.userIdentity, streamName: config.streamName)
        
        api.request(request) { [weak self] result in
            switch result {
            case .success:
                break
            case let .failure(error):
                self?.handleError(error)
            }
        }

        connectChat() /// Chat is not essential so connect it separately
    }
    
    func playerManager(_ playerManager: PlayerManager, didDisconnectWithError error: Error) {
        handleError(error)
    }
}
