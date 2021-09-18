//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

struct Speaker: Hashable {
    let identity: String
    var cameraTrack: VideoTrack? = nil
    var shouldMirrorCameraVideo: Bool // True for local participant using front camera
    var isMuted: Bool
    var displayName: String
    
    static func == (lhs: Speaker, rhs: Speaker) -> Bool {
        lhs.identity == rhs.identity
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(identity)
    }

    init(localParticipant: LocalParticipant) {
        identity = localParticipant.identity
        cameraTrack = localParticipant.cameraTrack
        shouldMirrorCameraVideo = true
        isMuted = !localParticipant.isMicOn
        displayName = "You"
    }
    
    // TODO: Rename parameter?
    init(remoteParticipant: RoomRemoteParticipant) {
        identity = remoteParticipant.identity
        cameraTrack = remoteParticipant.cameraTrack
        shouldMirrorCameraVideo = false
        isMuted = !remoteParticipant.isMicOn
        displayName = remoteParticipant.identity
    }
    
    // For UI previews
    init(
        identity: String,
        cameraTrack: VideoTrack? = nil,
        shouldMirrorCameraVideo: Bool = false,
        isMuted: Bool = false,
        displayName: String
    ) {
        self.identity = identity
        self.cameraTrack = cameraTrack
        self.shouldMirrorCameraVideo = shouldMirrorCameraVideo
        self.isMuted = isMuted
        self.displayName = displayName
    }
}
