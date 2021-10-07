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
    @Published var isHandRaised = false {
        didSet {
            syncViewerDocumentManager.isHandRaised = isHandRaised
        }
    }
    private var api: API?
    private var playerManager: PlayerManager?
    private var roomManager: RoomManager!
    private var subscriptions = Set<AnyCancellable>()
    private let syncManager = SyncManager()
    let syncViewerDocumentManager = SyncViewerDocumentManager()
    var mapManager: SyncRaisedHandsMapManager!
    @Published var config: StreamConfig!
    private var token: String!
    @Published var haveSpeakerInvite = false

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

        syncManager.syncClientPublisher
            .sink { [weak self] in self?.handleSyncConnect()}
            .store(in: &subscriptions)
        
        syncViewerDocumentManager.tokenPublisher
            .sink { [weak self] _ in
                print("Received token from publisher")
                self?.haveSpeakerInvite = true
            }
            .store(in: &subscriptions)

        playerManager.delegate = self
    }

    // TODO: Move this out
    func sendSpeakerInvite(userIdentity: String) {
        let request = SendSpeakerInviteRequest(userIdentity: userIdentity, roomName: config.streamName, roomSID: syncManager.roomSID)
        
        api?.request(request) { result in
            print(result)
        }
    }
    
    private func handleSyncConnect() {
        syncViewerDocumentManager.configure(client: syncManager.client!, roomSID: syncManager.roomSID)
        mapManager.configure(client: syncManager.client!, roomSID: syncManager.roomSID)
        
        switch config.role {
        case .host, .speaker:
            connectToRoom()
        case .viewer:
            playerManager?.configure(accessToken: token)
            playerManager?.connect()
        }
    }
    
    func connect() {
        guard let api = api else { return }
        
        state = .connecting
 
        switch config.role {
        case .host, .speaker:
            let request = TokenRequest(userIdentity: config.userIdentity, roomName: config.streamName)
            
            api.request(request) { [weak self] result in
                switch result {
                case let .success(response):
                    self?.token = response.token
                    self?.syncManager.configure(token: response.token, roomSID: response.roomSid)
                case let .failure(error):
                    self?.handleError(error)
                }
            }
        case .viewer:
            let request = StreamTokenRequest(userIdentity: config.userIdentity, roomName: config.streamName)
            
            api.request(request) { [weak self] result in
                switch result {
                case let .success(response):
                    self?.token = response.token
                    self?.syncManager.configure(token: response.token, roomSID: response.roomSid)
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
    
    func moveToSpeakers() {
        playerManager?.pause()
        state = .connecting
        token = syncViewerDocumentManager.videoRoomToken
        config = StreamConfig(streamName: config.streamName, userIdentity: config.userIdentity, role: .speaker)
        connectToRoom()
    }
    
    func moveToViewers() {
        roomManager.disconnect()
        state = .connecting
        config = StreamConfig(streamName: config.streamName, userIdentity: config.userIdentity, role: .viewer)
        playerManager?.connect()
    }
    
    func connectToRoom() {
        roomManager.localParticipant.isCameraOn = true
        roomManager.localParticipant.isMicOn = true
        roomManager.connect(roomName: config.streamName, accessToken: token)
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
