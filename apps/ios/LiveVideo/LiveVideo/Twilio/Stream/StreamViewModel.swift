//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import TwilioLivePlayer

class StreamViewModel: ObservableObject {
    enum AlertIdentifier: String, Identifiable {
        case error
        case receivedSpeakerInvite
        case streamEndedByHost
        case streamWillEndIfHostLeaves
        case viewerConnected
        
        var id: String { rawValue }
    }
    
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
    @Published var alertIdentifier: AlertIdentifier?
    private(set) var error: Error?
    private var haveShownViewerConnectedAlert = false
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
                    switch streamManager.config.role {
                    case .viewer:
                        if !self.haveShownViewerConnectedAlert {
                            self.haveShownViewerConnectedAlert = true
                            self.alertIdentifier = .viewerConnected
                        }
                    case .host, .speaker:
                        break
                    }
                }
            }
            .store(in: &subscriptions)

        streamManager.errorPublisher
            .sink { [weak self] error in self?.handleError(error) }
            .store(in: &subscriptions)

        viewerStore.speakerInvitePublisher
            .sink { [weak self] in
                self?.alertIdentifier = .receivedSpeakerInvite
            }
            .store(in: &subscriptions)
    }

    private func handleError(_ error: Error) {
        streamManager.disconnect()
        
        if let error = error as? LiveVideoError, error.isStreamEndedByHostError {
            alertIdentifier = .streamEndedByHost
        } else {
            self.error = error
            alertIdentifier = .error
        }
    }
}
