//
//  Copyright (C) 2022 Twilio, Inc.
//

import Foundation

class SpeakerVideoViewModelFactory {
    private var speakersMap: SyncUsersMap!

    func configure(speakersMap: SyncUsersMap) {
        self.speakersMap = speakersMap
    }
    
    func makeSpeaker(participant: LocalParticipantManager) -> SpeakerVideoViewModel {
        let isHost = speakersMap.host?.identity == participant.identity
        return SpeakerVideoViewModel(participant: participant, isHost: isHost)
    }

    func makeSpeaker(participant: RemoteParticipantManager) -> SpeakerVideoViewModel {
        let isHost = speakersMap.host?.identity == participant.identity
        return SpeakerVideoViewModel(participant: participant, isHost: isHost)
    }
}
