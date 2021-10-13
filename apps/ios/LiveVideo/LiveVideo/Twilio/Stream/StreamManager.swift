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
    @Published var showError = false // TODO: Move out?
    @Published var error: Error? {
        didSet {
            showError = error != nil
        }
    }
    @Published var isHandRaised = false {
        didSet {
            viewerStore.isHandRaised = isHandRaised
        }
    }
    private var api: API?
    private var playerManager: PlayerManager?
    private var roomManager: RoomManager!
    private var subscriptions = Set<AnyCancellable>()
    private let syncManager = SyncManager()
    private var viewerStore: ViewerStore!
    var raisedHandsStore: RaisedHandsStore!
    private let speakersStore = SpeakersStore()
    @Published var config: StreamConfig!
    @Published var haveSpeakerInvite = false

    func configure(
        roomManager: RoomManager,
        playerManager: PlayerManager,
        api: API,
        viewerStore: ViewerStore
    ) {
        self.roomManager = roomManager
        self.playerManager = playerManager
        self.api = api
        self.viewerStore = viewerStore
        
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

        viewerStore.speakerInvitePublisher
            .sink { [weak self] in
                self?.haveSpeakerInvite = true
            }
            .store(in: &subscriptions)

        playerManager.delegate = self
    }
    
    func connect() {
        guard api != nil else { return }
        
        state = .connecting
        fetchToken()
    }
    
    func disconnect() {
        roomManager.disconnect()
        playerManager?.disconnect()
        syncManager.disconnect()
        raisedHandsStore.disconnect() // TODO: Move
        viewerStore.disconnect() // TODO: Move
        player = nil
        state = .disconnected
        
        // TODO: Delete stream
    }
    
    func moveToSpeakers() {
        state = .connecting
        playerManager?.disconnect()
        config.role = .speaker
        fetchToken()
    }
    
    func moveToViewers() {
        state = .connecting
        roomManager.disconnect()
        config.role = .viewer
        fetchToken()
    }

    private func fetchToken() {
        let request = TokenRequest(userIdentity: config.userIdentity, roomName: config.streamName, role: config.role)
        
        api?.request(request) { [weak self] result in
            switch result {
            case let .success(response):
                self?.connectSync(
                    token: response.token,
                    viewerDocumentName: response.syncObjectNames.viewerDocument,
                    raisedHandsMapName: response.syncObjectNames.raisedHandsMap,
                    speakersMapName: response.syncObjectNames.speakersMap
                )
            case let .failure(error):
                self?.handleError(error)
            }
        }
    }
    
    private func connectSync(
        token: String,
        viewerDocumentName: String,
        raisedHandsMapName: String,
        speakersMapName: String
    ) {
        guard !syncManager.isConnected else {
            connectRoomOrPlayer(token: token)
            return
        }
        
        viewerStore.documentName = viewerDocumentName
        raisedHandsStore.mapName = raisedHandsMapName
        speakersStore.mapName = speakersMapName

        let stores: [SyncStoring] = [viewerStore, raisedHandsStore, speakersStore]
        
        syncManager.connect(token: token, stores: stores) { [weak self] error in
            if let error = error {
                self?.handleError(error)
                return
            }
            
            self?.connectRoomOrPlayer(token: token)
        }
    }
    
    private func connectRoomOrPlayer(token: String) {
        switch self.config.role {
        case .host, .speaker:
            roomManager.localParticipant.isCameraOn = true // TODO: Move
            roomManager.localParticipant.isMicOn = true
            roomManager.connect(roomName: config.streamName, accessToken: token)
        case .viewer:
            playerManager?.connect(accessToken: token)
        }
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
