//
//  Copyright (C) 2021 Twilio, Inc.
//

import TwilioVideo

/// Speaker abstraction so the UI can handle local and remote participants the same way.
struct SpeakerVideoViewModel {
    let identity: String
    let displayName: String
    let isYou: Bool
    let isMuted: Bool
    let isDominantSpeaker: Bool
    let dominantSpeakerStartTime: Date
    var cameraTrack: VideoTrack?
    var shouldMirrorCameraVideo: Bool

    init(participant: LocalParticipantManager) {
        identity = participant.identity
        displayName = "You"
        isYou = true
        isMuted = !participant.isMicOn
        isDominantSpeaker = false
        dominantSpeakerStartTime = .distantPast

        if let cameraTrack = participant.cameraTrack, cameraTrack.isEnabled {
            self.cameraTrack = cameraTrack
        } else {
            cameraTrack = nil
        }
        
        shouldMirrorCameraVideo = true
    }
    
    init(participant: RemoteParticipantManager) {
        identity = participant.identity
        displayName = participant.identity
        isYou = false
        isMuted = !participant.isMicOn
        isDominantSpeaker = participant.isDominantSpeaker
        dominantSpeakerStartTime = participant.dominantSpeakerStartTime
        cameraTrack = participant.cameraTrack
        shouldMirrorCameraVideo = false
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
