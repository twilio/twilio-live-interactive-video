//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation
import Combine

class LocalParticipantViewModel: ObservableObject {
    @Published var isMicOn = false {
        didSet {
            localParticipant.isMicOn = isMicOn
        }
    }
    @Published var isCameraOn = false {
        didSet {
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
        notificationCenter.publisher(for: .localParticipantDidChangeMic)
            .sink() { _ in self.isMicOn = self.localParticipant.isMicOn }
            .store(in: &subscriptions)

        notificationCenter.publisher(for: .localParticipantDidChangeCameraTrack)
            .sink() { _ in self.isCameraOn = self.localParticipant.isCameraOn }
            .store(in: &subscriptions)
    }
}
