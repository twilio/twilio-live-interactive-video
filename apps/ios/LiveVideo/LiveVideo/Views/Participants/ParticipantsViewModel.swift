//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine

class ParticipantsViewModel: ObservableObject {
    @Published var speakers: [SyncUsersStore.User] = []
    @Published var viewersWithRaisedHand: [SyncUsersStore.User] = []
    @Published var viewersWithoutRaisedHand: [SyncUsersStore.User] = []
    @Published var viewerCount = 0
    @Published var haveNewRaisedHand = false
    @Published var showError = false
    @Published var showSpeakerInviteSent = false
    private(set) var error: Error? {
        didSet {
            showError = error != nil
        }
    }
    private var newRaisedHands: [SyncUsersStore.User] = [] {
        didSet {
            haveNewRaisedHand = !newRaisedHands.isEmpty
        }
    }
    private var streamManager: StreamManager!
    private var api: API!
    private var roomManager: RoomManager!
    private var speakersStore: SyncUsersStore!
    private var viewersStore: SyncUsersStore!
    private var raisedHandsStore: SyncUsersStore!
    private var subscriptions = Set<AnyCancellable>()
    
    func configure(
        streamManager: StreamManager,
        api: API,
        roomManager: RoomManager,
        speakersStore: SyncUsersStore,
        viewersStore: SyncUsersStore,
        raisedHandsStore: SyncUsersStore
    ) {
        self.streamManager = streamManager
        self.api = api
        self.roomManager = roomManager
        self.speakersStore = speakersStore
        self.viewersStore = viewersStore
        self.raisedHandsStore = raisedHandsStore

        streamManager.$state
            .sink { [weak self] _ in self?.handleStreamStateChange() }
            .store(in: &subscriptions)

        speakersStore.userAddedPublisher
            .sink { [weak self] user in self?.addSpeaker(user: user) }
            .store(in: &subscriptions)

        speakersStore.userRemovedPublisher
            .sink { [weak self] user in self?.removeSpeaker(user: user) }
            .store(in: &subscriptions)

        viewersStore.userAddedPublisher
            .sink { [weak self] user in self?.addViewer(user: user) }
            .store(in: &subscriptions)

        viewersStore.userRemovedPublisher
            .sink { [weak self] user in self?.removeViewer(user: user) }
            .store(in: &subscriptions)
        
        raisedHandsStore.userAddedPublisher
            .sink { [weak self] user in self?.addRaisedHand(user: user) }
            .store(in: &subscriptions)

        raisedHandsStore.userRemovedPublisher
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
    
    private func handleStreamStateChange() {
        switch streamManager.state {
        case .disconnected:
            speakers = []
            viewersWithRaisedHand = []
            viewersWithoutRaisedHand = []
            newRaisedHands = []
            viewerCount = 0
            error = nil
        case .connected:
            speakersStore.users.forEach { addSpeaker(user: $0) }
            viewersStore.users.forEach { addViewer(user: $0) }
            raisedHandsStore.users.forEach { addRaisedHand(user: $0) }
        case .connecting, .changingRole:
            break
        }
    }
    
    private func addSpeaker(user: SyncUsersStore.User) {
        speakers.append(user)
    }
    
    private func removeSpeaker(user: SyncUsersStore.User) {
        speakers.removeAll { $0.identity == user.identity }
    }

    private func addViewer(user: SyncUsersStore.User) {
        guard viewersWithRaisedHand.first(where: { $0.identity == user.identity }) == nil else {
            return
        }
        
        viewersWithoutRaisedHand.append(user)
        updateViewerCount()
    }
    
    private func removeViewer(user: SyncUsersStore.User) {
        viewersWithoutRaisedHand.removeAll { $0.identity == user.identity }
        updateViewerCount()
    }

    private func addRaisedHand(user: SyncUsersStore.User) {
        viewersWithRaisedHand.append(user)
        newRaisedHands.append(user)
        viewersWithoutRaisedHand.removeAll { $0.identity == user.identity }
        updateViewerCount()
    }
    
    private func removeRaisedHand(user: SyncUsersStore.User) {
        viewersWithRaisedHand.removeAll { $0.identity == user.identity }
        newRaisedHands.removeAll { $0.identity == user.identity }

        if viewersStore.users.first(where: { $0.identity == user.identity }) != nil {
            viewersWithoutRaisedHand.insert(user, at: 0)
        }

        updateViewerCount()
    }
    
    private func updateViewerCount() {
        viewerCount = viewersWithoutRaisedHand.count + viewersWithRaisedHand.count
    }
}

extension SyncUsersStore.User {
    var displayName: String
}
