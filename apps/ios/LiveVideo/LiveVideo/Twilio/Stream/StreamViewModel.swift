//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import TwilioPlayer

class StreamViewModel: ObservableObject {
    @Published var isHandRaised = false {
        didSet {
            let request = RaiseHandRequest(
                userIdentity: streamManager.config.userIdentity,
                streamName: streamManager.config.streamName,
                handRaised: isHandRaised
            )
            
            api.request(request) { [weak self] result in
                switch result {
                case .success:
                    break
                case let .failure(error):
                    self?.handleError(error)
                }
            }
        }
    }
    @Published var showError = false
    @Published var haveSpeakerInvite = false
    private(set) var error: Error? {
        didSet {
            showError = error != nil
        }
    }
    private var streamManager: StreamManager!
    private var api: API!
    private var viewerStore: ViewerStore!
    private var subscriptions = Set<AnyCancellable>()

    func configure(
        streamManager: StreamManager,
        api: API,
        viewerStore: ViewerStore
    ) {
        self.streamManager = streamManager
        self.api = api
        self.viewerStore = viewerStore
        
        streamManager.errorPublisher
            .sink { [weak self] error in self?.error = error }
            .store(in: &subscriptions)

        viewerStore.speakerInvitePublisher
            .sink { [weak self] in
                self?.haveSpeakerInvite = true
            }
            .store(in: &subscriptions)
    }
    
    private func handleError(_ error: Error) {
        streamManager.disconnect()
        self.error = error
    }
}
