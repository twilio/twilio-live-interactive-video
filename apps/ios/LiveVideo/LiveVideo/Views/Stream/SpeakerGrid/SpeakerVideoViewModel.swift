//
//  Copyright (C) 2021 Twilio, Inc.
//

import TwilioVideo
import Foundation

struct SpeakerVideoViewModel {
    let identity: String
    let displayName: String
    var cameraTrack: VideoTrack? // TODO: Don't use bindings and make let?
    var shouldMirrorCameraVideo: Bool // True for local participant using front camera
    let isMuted: Bool
    let isDominantSpeaker: Bool
    let dominantSpeakerStartTime: Date
    
    init(localParticipant participant: LocalParticipantManager) {
        identity = participant.identity
        
        if let cameraTrack = participant.cameraTrack, cameraTrack.isEnabled {
            self.cameraTrack = cameraTrack
        } else {
            cameraTrack = nil
        }
        
        shouldMirrorCameraVideo = true
        isMuted = !participant.isMicOn
        displayName = "You"
        isDominantSpeaker = false // TODO: Improve this?
        dominantSpeakerStartTime = .distantPast
    }
    
    init(remoteParticipant participant: RemoteParticipantManager) {
        identity = participant.identity
        cameraTrack = participant.cameraTrack
        shouldMirrorCameraVideo = false
        isMuted = !participant.isMicOn
        displayName = participant.identity
        isDominantSpeaker = participant.isDominantSpeaker
        dominantSpeakerStartTime = participant.dominantSpeakerStartTime
    }
    
    /// Only for preview provider.
    init(
        identity: String,
        cameraTrack: VideoTrack? = nil,
        shouldMirrorCameraVideo: Bool = false,
        isMuted: Bool = false,
        displayName: String? = nil,
        isDominantSpeaker: Bool = false,
        dominantSpeakerTimestamp: Date = .distantPast
    ) {
        self.identity = identity
        self.cameraTrack = cameraTrack
        self.shouldMirrorCameraVideo = shouldMirrorCameraVideo
        self.isMuted = isMuted
        self.displayName = displayName ?? identity
        self.isDominantSpeaker = isDominantSpeaker
        self.dominantSpeakerStartTime = dominantSpeakerTimestamp
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
