//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine

class ParticipantsViewModel: ObservableObject {
    @Published var speakers: [SyncUsersMap.User] = []
    @Published var viewersWithRaisedHand: [SyncUsersMap.User] = []
    @Published var viewersWithoutRaisedHand: [SyncUsersMap.User] = []
    @Published var viewerCount = 0
    @Published var haveNewRaisedHand = false
    @Published var showError = false
    @Published var showSpeakerInviteSent = false
    private(set) var error: Error? {
        didSet {
            showError = error != nil
        }
    }
    private var newRaisedHands: [SyncUsersMap.User] = [] {
        didSet {
            haveNewRaisedHand = !newRaisedHands.isEmpty
        }
    }
    private var streamManager: StreamManager!
    private var api: API!
    private var roomManager: RoomManager!
    private var speakersMap: SyncUsersMap!
    private var viewersMap: SyncUsersMap!
    private var raisedHandsMap: SyncUsersMap!
    private var subscriptions = Set<AnyCancellable>()
    
    func configure(
        streamManager: StreamManager,
        api: API,
        roomManager: RoomManager,
        speakersMap: SyncUsersMap,
        viewersMap: SyncUsersMap,
        raisedHandsMap: SyncUsersMap
    ) {
        self.streamManager = streamManager
        self.api = api
        self.roomManager = roomManager
        self.speakersMap = speakersMap
        self.viewersMap = viewersMap
        self.raisedHandsMap = raisedHandsMap

        streamManager.$state
            .sink { [weak self] state in self?.handleStreamStateChange(state) }
            .store(in: &subscriptions)
        
        speakersMap.userAddedPublisher
            .sink { [weak self] user in self?.addSpeaker(user: user) }
            .store(in: &subscriptions)

        speakersMap.userRemovedPublisher
            .sink { [weak self] user in self?.removeSpeaker(user: user) }
            .store(in: &subscriptions)

        viewersMap.userAddedPublisher
            .sink { [weak self] user in self?.addViewer(user: user) }
            .store(in: &subscriptions)

        viewersMap.userRemovedPublisher
            .sink { [weak self] user in self?.removeViewer(user: user) }
            .store(in: &subscriptions)
        
        raisedHandsMap.userAddedPublisher
            .sink { [weak self] user in self?.addRaisedHand(user: user) }
            .store(in: &subscriptions)

        raisedHandsMap.userRemovedPublisher
            .sink { [weak self] user in self?.removeRaisedHand(user: user) }
            .store(in: &subscriptions)
    }
    
    func sendSpeakerInvite(userIdentity: String) {
        let request = SendSpeakerInviteRequest(userIdentity: userIdentity, roomSID: roomManager.roomSID!)

        api.request(request) { [weak self] result in
            switch result {
            case .success:
                self?.showSpeakerInviteSent = true
            case let .failure(error):
                self?.error = error
            }
        }
    }

    private func handleStreamStateChange(_ state: StreamManager.State) {
        switch state {
        case .disconnected:
            speakers = []
            viewersWithRaisedHand = []
            viewersWithoutRaisedHand = []
            newRaisedHands = []
            viewerCount = 0
            error = nil
        case .connected:
            guard speakers.count == .zero else {
                return // The user just changed role so don't load everything again
            }
            
            speakersMap.users.forEach { addSpeaker(user: $0) }
            viewersMap.users.forEach { addViewer(user: $0) }
            raisedHandsMap.users.forEach { addRaisedHand(user: $0) }
        case .connecting, .changingRole:
            break
        }
    }
    
    private func addSpeaker(user: SyncUsersMap.User) {
        speakers.append(user)
    }
    
    private func removeSpeaker(user: SyncUsersMap.User) {
        speakers.removeAll { $0.identity == user.identity }
    }

    private func addViewer(user: SyncUsersMap.User) {
        guard viewersWithRaisedHand.first(where: { $0.identity == user.identity }) == nil else {
            return
        }
        
        viewersWithoutRaisedHand.append(user)
        updateViewerCount()
    }
    
    private func removeViewer(user: SyncUsersMap.User) {
        viewersWithoutRaisedHand.removeAll { $0.identity == user.identity }
        updateViewerCount()
    }

    private func addRaisedHand(user: SyncUsersMap.User) {
        viewersWithRaisedHand.append(user)
        newRaisedHands.append(user)
        viewersWithoutRaisedHand.removeAll { $0.identity == user.identity }
        updateViewerCount()
    }
    
    private func removeRaisedHand(user: SyncUsersMap.User) {
        viewersWithRaisedHand.removeAll { $0.identity == user.identity }
        newRaisedHands.removeAll { $0.identity == user.identity }

        if viewersMap.users.first(where: { $0.identity == user.identity }) != nil {
            viewersWithoutRaisedHand.insert(user, at: 0)
        }

        updateViewerCount()
    }
    
    private func updateViewerCount() {
        viewerCount = viewersWithoutRaisedHand.count + viewersWithRaisedHand.count
    }
}

extension SyncUsersMap.User {
    var displayName: String {
        isHost ? "\(identity) (Host)" : identity
    }
}
