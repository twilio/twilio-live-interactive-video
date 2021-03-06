//
//  Copyright (C) 2021 Twilio, Inc.
//

import TwilioVideo

/// Speaker abstraction so the UI can handle local and remote participants the same way.
struct SpeakerVideoViewModel {
    var identity = ""
    var displayName = ""
    var isYou = false
    var isMuted = false
    var dominantSpeakerStartTime: Date = .distantPast
    var isDominantSpeaker = false
    var cameraTrack: VideoTrack?
    var shouldMirrorCameraVideo = false

    init(participant: LocalParticipantManager, isHost: Bool) {
        identity = participant.identity
        displayName = DisplayNameFactory().makeDisplayName(identity: participant.identity, isHost: isHost, isYou: true)
        isYou = true
        isMuted = !participant.isMicOn

        if let cameraTrack = participant.cameraTrack, cameraTrack.isEnabled {
            self.cameraTrack = cameraTrack
        } else {
            cameraTrack = nil
        }
        
        shouldMirrorCameraVideo = true
    }
    
    init(participant: RemoteParticipantManager, isHost: Bool) {
        identity = participant.identity
        displayName = DisplayNameFactory().makeDisplayName(identity: participant.identity, isHost: isHost, isYou: false)
        isMuted = !participant.isMicOn
        isDominantSpeaker = participant.isDominantSpeaker
        dominantSpeakerStartTime = participant.dominantSpeakerStartTime
        cameraTrack = participant.cameraTrack
    }
}

extension SpeakerVideoViewModel: Hashable {
    static func == (lhs: SpeakerVideoViewModel, rhs: SpeakerVideoViewModel) -> Bool {
        lhs.identity == rhs.identity
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identity)
    }
}
