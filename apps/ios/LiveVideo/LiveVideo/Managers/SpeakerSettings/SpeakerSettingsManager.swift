//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import Foundation

class SpeakerSettingsManager: ObservableObject {
    @Published var isMicOn = false {
        didSet {
            guard oldValue != isMicOn else { return }
            
            localParticipant?.isMicOn = isMicOn
        }
    }
    @Published var isCameraOn = false {
        didSet {
            guard oldValue != isCameraOn else { return }

            localParticipant?.isCameraOn = isCameraOn
        }
    }
    var localParticipant: LocalParticipantManager? {
        didSet {
            guard let localParticipant = localParticipant else { return }
            
            isMicOn = localParticipant.isMicOn
            isCameraOn = localParticipant.isCameraOn
        }
    }
    private let notificationCenter = NotificationCenter.default
    private var subscriptions = Set<AnyCancellable>()

    init() {
        notificationCenter.publisher(for: .localParticipantDidChange)
            .sink { [weak self] _ in
                guard let self = self, let localParticipant = self.localParticipant else { return }
                
                self.isMicOn = localParticipant.isMicOn
                self.isCameraOn = localParticipant.isCameraOn
            }
            .store(in: &subscriptions)
    }
}
