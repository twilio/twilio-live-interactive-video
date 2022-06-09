//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import TwilioLivePlayer

class StreamViewModel: ObservableObject {
    enum AlertIdentifier: String, Identifiable {
        case fatalError
        case informativeError
        case receivedSpeakerInvite
        case recordingIsInProgress
        case speakerMovedToViewersByHost
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
    private var userDocument: SyncUserDocument!
    private var streamDocument: SyncStreamDocument!
    private var speakerSettingsManager: SpeakerSettingsManager!
    private var subscriptions = Set<AnyCancellable>()

    func configure(
        streamManager: StreamManager,
        speakerSettingsManager: SpeakerSettingsManager,
        api: API,
        userDocument: SyncUserDocument,
        streamDocument: SyncStreamDocument
    ) {
        self.streamManager = streamManager
        self.speakerSettingsManager = speakerSettingsManager
        self.api = api
        self.userDocument = userDocument
        self.streamDocument = streamDocument

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
                    
                    if let error = self.streamDocument.recordError {
                        self.handleError(error) /// Handle record error that was received while connecting
                    } else if self.streamDocument.isRecording {
                        self.handleRecordingEnabled()
                    }
                }
            }
            .store(in: &subscriptions)

        streamManager.errorPublisher
            .sink { [weak self] error in self?.handleError(error) }
            .store(in: &subscriptions)

        userDocument.speakerInvitePublisher
            .sink { [weak self] in
                self?.alertIdentifier = .receivedSpeakerInvite
            }
            .store(in: &subscriptions)

        streamDocument.$isRecording
            .filter { $0 }
            .sink { [weak self] _ in
                guard self?.streamManager.state == .connected else {
                    return /// Don't show recording message until after the stream is connected
                }
                
                self?.handleRecordingEnabled()
            }
            .store(in: &subscriptions)

        streamDocument.$recordError
            .compactMap { $0 }
            .sink { [weak self] error in
                guard self?.streamManager.state == .connected else {
                    return /// Record errors are not fatal so wait until after the stream is connected to show them
                }
                
                self?.handleError(error) }
            .store(in: &subscriptions)
    }

    private func handleError(_ error: Error) {
        if error.isRecordError {
            guard streamManager.config.role == .host else {
                return
            }

            self.error = error
            alertIdentifier = .informativeError
        } else {
            streamManager.disconnect()
            
            if error.isStreamEndedByHostError {
                alertIdentifier = .streamEndedByHost
            } else if error.isSpeakerMovedToViewersByHostError {
                alertIdentifier = .speakerMovedToViewersByHost
                streamManager.changeRole(to: .viewer)
            } else {
                self.error = error
                alertIdentifier = .fatalError
            }
        }
    }
    
    private func handleRecordingEnabled() {
        switch streamManager.config.role {
        case .host, .speaker:
            self.alertIdentifier = .recordingIsInProgress
        case .viewer:
            break
        }
    }
}

private extension Error {
    var isSpeakerMovedToViewersByHostError: Bool {
        if case .speakerMovedToViewersByHost = self as? LiveVideoError {
            return true
        }

        return false
    }

    var isStreamEndedByHostError: Bool {
        if case .streamEndedByHost = self as? LiveVideoError {
            return true
        }

        return false
    }

    var isRecordError: Bool {
        if case .recordError = self as? LiveVideoError {
            return true
        }

        return false
    }
}
