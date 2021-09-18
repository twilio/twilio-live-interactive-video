//
//  Copyright (C) 2020 Twilio, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import TwilioVideo

class LocalParticipant: NSObject {
    let identity: String
    var cameraTrack: VideoTrack?
    var shouldMirrorCameraVideo = true
    var isMicOn: Bool {
        get {
            micTrack?.isEnabled ?? false
        }
        set {
            if newValue {
                guard micTrack == nil, let micTrack = LocalAudioTrack(options: nil, enabled: true, name: TrackName.mic) else { return }
                
                self.micTrack = micTrack
                participant?.publishAudioTrack(micTrack)
            } else {
                guard let micTrack = micTrack else { return }
                
                participant?.unpublishAudioTrack(micTrack)
                self.micTrack = nil
            }
            
            notificationCenter.post(name: .localParticipantDidChangeMic, object: self)
        }
    }
    var isCameraOn: Bool {
        get {
            cameraManager?.track.isEnabled ?? false
        }
        set {
            if newValue {
                guard
                    cameraManager == nil,
                    let cameraManager = CameraManager(position: .front)
                else {
                    return
                }
                
                self.cameraManager = cameraManager
                cameraManager.delegate = self
                participant?.publishCameraTrack(cameraManager.track.track)
                cameraTrack = cameraManager.track
            } else {
                guard let cameraManager = cameraManager else { return }
                
                participant?.unpublishVideoTrack(cameraManager.track.track)
                self.cameraManager = nil
                cameraTrack = nil
            }
            
            notificationCenter.post(name: .localParticipantDidChangeCameraTrack, object: self)
        }
    }
    var participant: TwilioVideo.LocalParticipant? {
        didSet {
            participant?.delegate = self
        }
    }
    var localCameraTrack: TwilioVideo.LocalVideoTrack? { cameraManager?.track.track }
    private(set) var micTrack: LocalAudioTrack?
    private var cameraManager: CameraManager?
    private let notificationCenter = NotificationCenter.default

    init(identity: String) {
        self.identity = identity
    }
}

extension LocalParticipant: LocalParticipantDelegate {
    func localParticipantDidFailToPublishVideoTrack(
        participant: TwilioVideo.LocalParticipant,
        videoTrack: TwilioVideo.LocalVideoTrack,
        error: Error
    ) {
        print("Failed to publish video track: \(error)")
    }
    
    func localParticipantDidFailToPublishAudioTrack(
        participant: TwilioVideo.LocalParticipant,
        audioTrack: LocalAudioTrack,
        error: Error
    ) {
        print("Failed to publish audio track: \(error)")
    }
}

extension LocalParticipant: CameraManagerDelegate {
    func trackSourceWasInterrupted(track: LocalVideoTrack) {
//        track.track.isEnabled = false
//        sendUpdate()
    }
    
    func trackSourceInterruptionEnded(track: LocalVideoTrack) {
//        track.track.isEnabled = true
//        sendUpdate()
    }
}

private extension TwilioVideo.LocalParticipant {
    func publishCameraTrack(_ track: TwilioVideo.LocalVideoTrack) {
        let publicationOptions = LocalTrackPublicationOptions(priority: .low)
        publishVideoTrack(track, publicationOptions: publicationOptions)
    }
}
