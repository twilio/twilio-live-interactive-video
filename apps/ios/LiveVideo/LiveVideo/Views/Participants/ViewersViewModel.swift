//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine

class ViewersViewModel: ObservableObject {
    struct Viewer: Identifiable {
        let userIdentity: String
        var id: String { userIdentity }
     
        init(viewer: ViewersStore.Viewer) {
            userIdentity = viewer.userIdentity
        }
        
        init(raisedHand: RaisedHandsStore.RaisedHand) {
            userIdentity = raisedHand.userIdentity
        }
    }
    
    @Published var viewersWithRaisedHand: [Viewer] = []
    @Published var viewersWithoutRaisedHand: [Viewer] = []
    @Published var viewerCount = 0
    @Published var haveNewRaisedHand = false
    private var newRaisedHands: [Viewer] = [] {
        didSet {
            haveNewRaisedHand = !newRaisedHands.isEmpty
        }
    }
    private var streamManager: StreamManager!
    private var viewersStore: ViewersStore!
    private var raisedHandsStore: RaisedHandsStore!
    private var subscriptions = Set<AnyCancellable>()

    func configure(streamManager: StreamManager, viewersStore: ViewersStore, raisedHandsStore: RaisedHandsStore) {
        self.streamManager = streamManager
        self.viewersStore = viewersStore
        self.raisedHandsStore = raisedHandsStore

        streamManager.$state
            .sink { [weak self] _ in self?.handleStreamStateChange() }
            .store(in: &subscriptions)

        viewersStore.viewerAddedPublisher
            .sink { [weak self] viewer in self?.addViewer(viewer) }
            .store(in: &subscriptions)

        viewersStore.viewerRemovedPublisher
            .sink { [weak self] viewer in self?.removeViewer(viewer) }
            .store(in: &subscriptions)
        
        raisedHandsStore.raisedHandAddedPublisher
            .sink { [weak self] raisedHand in self?.addRaisedHand(raisedHand) }
            .store(in: &subscriptions)

        raisedHandsStore.raisedHandRemovedPublisher
            .sink { [weak self] raisedHand in self?.removeRaisedHand(raisedHand) }
            .store(in: &subscriptions)
    }
    
    private func handleStreamStateChange() {
        switch streamManager.state {
        case .disconnected:
            viewersWithRaisedHand = []
            viewersWithoutRaisedHand = []
            newRaisedHands = []
            viewerCount = 0
        case .connected:
            viewersStore.viewers.forEach { addViewer($0) }
            raisedHandsStore.raisedHands.forEach { addRaisedHand($0) }
        case .connecting, .changingRole:
            break
        }
    }

    private func addViewer(_ viewer: ViewersStore.Viewer) {
        guard viewersWithRaisedHand.first(where: { $0.userIdentity == viewer.userIdentity }) == nil else {
            return
        }
        
        let viewer = Viewer(viewer: viewer)
        viewersWithoutRaisedHand.append(viewer)
        updateViewerCount()
    }
    
    private func removeViewer(_ viewer: ViewersStore.Viewer) {
        viewersWithoutRaisedHand.removeAll { $0.userIdentity == viewer.userIdentity }
        updateViewerCount()
    }

    private func addRaisedHand(_ raisedHand: RaisedHandsStore.RaisedHand) {
        let viewer = Viewer(raisedHand: raisedHand)
        viewersWithRaisedHand.append(viewer)
        newRaisedHands.append(viewer)
        viewersWithoutRaisedHand.removeAll { $0.userIdentity == raisedHand.userIdentity }
        updateViewerCount()
    }
    
    private func removeRaisedHand(_ raisedHand: RaisedHandsStore.RaisedHand) {
        viewersWithRaisedHand.removeAll { $0.userIdentity == raisedHand.userIdentity }
        newRaisedHands.removeAll { $0.userIdentity == raisedHand.userIdentity }

        if viewersStore.viewers.first(where: { $0.userIdentity == raisedHand.userIdentity }) != nil {
            let viewer = Viewer(raisedHand: raisedHand)
            viewersWithoutRaisedHand.insert(viewer, at: 0)
        }

        updateViewerCount()
    }
    
    private func updateViewerCount() {
        viewerCount = viewersWithoutRaisedHand.count + viewersWithRaisedHand.count
    }
}
