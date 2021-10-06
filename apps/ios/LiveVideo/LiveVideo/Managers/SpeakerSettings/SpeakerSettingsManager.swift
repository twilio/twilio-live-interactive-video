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
    private var localParticipant: LocalParticipantManager?
    private var subscriptions = Set<AnyCancellable>()
    
    func configure(localParticipant: LocalParticipantManager) {
        self.localParticipant = localParticipant
        
        isMicOn = localParticipant.isMicOn
        isCameraOn = localParticipant.isCameraOn
        
        localParticipant.changePublisher
            .sink { [weak self] participant in
                guard let self = self else { return }
                
                self.isMicOn = participant.isMicOn
                self.isCameraOn = participant.isCameraOn
            }
            .store(in: &subscriptions)
    }
}
