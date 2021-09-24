//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation
import Combine

class LocalParticipantViewModel: ObservableObject {
    @Published var isMicOn = false {
        didSet {
            guard oldValue != isMicOn else { return }
            
            localParticipant.isMicOn = isMicOn
        }
    }
    @Published var isCameraOn = false {
        didSet {
            guard oldValue != isCameraOn else { return }

            localParticipant.isCameraOn = isCameraOn
        }
    }
    private var subscriptions = Set<AnyCancellable>()

    var localParticipant: LocalParticipant! {
        didSet {
            isMicOn = localParticipant.isMicOn
            isCameraOn = localParticipant.isCameraOn
        }
    }
    
    init() {
        let notificationCenter = NotificationCenter.default

        // TODO: Need weak self?
        notificationCenter.publisher(for: .localParticipantDidChange)
            .sink() { _ in
                self.isMicOn = self.localParticipant.isMicOn
                self.isCameraOn = self.localParticipant.isCameraOn
            }
            .store(in: &subscriptions)
    }
}
