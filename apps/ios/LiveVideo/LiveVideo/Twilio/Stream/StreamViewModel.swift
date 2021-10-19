//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import TwilioLivePlayer

class StreamViewModel: ObservableObject {
    @Published var isHandRaised = false {
        didSet {
            guard streamManager.state == .connected else {
                return
            }
            
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
    @Published var haveSpeakerInvite = false
    @Published var showError = false
    private(set) var error: Error? {
        didSet {
            showError = error != nil
        }
    }
    private var streamManager: StreamManager!
    private var api: API!
    private var viewerStore: ViewerStore!
    private var speakerSettingsManager: SpeakerSettingsManager!
    private var subscriptions = Set<AnyCancellable>()

    func configure(
        streamManager: StreamManager,
        speakerSettingsManager: SpeakerSettingsManager,
        api: API,
        viewerStore: ViewerStore
    ) {
        self.streamManager = streamManager
        self.speakerSettingsManager = speakerSettingsManager
        self.api = api
        self.viewerStore = viewerStore

        streamManager.$state
            .sink { [weak self] state in
                guard let self = self, streamManager.config != nil else {
                    return
                }
                
                switch state {
                case .connecting, .changingRole:
                    switch streamManager.config.role {
                    case .host, .speaker:
                        self.speakerSettingsManager.isMicOn = true
                        self.speakerSettingsManager.isCameraOn = true
                    case .viewer:
                        self.speakerSettingsManager.isMicOn = false
                        self.speakerSettingsManager.isCameraOn = false
                        self.isHandRaised = false
                    }
                case .disconnected:
                    self.speakerSettingsManager.isMicOn = false
                    self.speakerSettingsManager.isCameraOn = false
                case .connected:
                    break
                }
            }
            .store(in: &subscriptions)

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
