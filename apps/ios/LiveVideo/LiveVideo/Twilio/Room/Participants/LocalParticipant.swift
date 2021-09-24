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
import Combine

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
            
            postChangeNotification()
        }
    }
    private var camera: CameraSource?

    var isCameraOn = false {
        didSet {
            guard oldValue != isCameraOn else { return }
            
            if isCameraOn {
                let frontCamera = CameraSource.captureDevice(position: .front)

                if (frontCamera != nil) {
                    let options = CameraSourceOptions { (builder) in
                        builder.orientationTracker = UserInterfaceTracker(scene: UIApplication.shared.keyWindow!.windowScene!)
                    }
                    
                    camera = CameraSource(options: options, delegate: self)
                    
                    localCameraTrack = TwilioVideo.LocalVideoTrack(source: camera!, enabled: true, name: TrackName.camera)
                    
                    camera!.startCapture(device: frontCamera!) { (captureDevice, videoFormat, error) in
                        if let error = error {
                            print("Start capture error: \(error)")
                        }
                    }

                    participant?.publishCameraTrack(localCameraTrack!)
                    cameraTrack = LocalVideoTrack(track: localCameraTrack!)
                }
            } else {
                participant?.unpublishVideoTrack(localCameraTrack!)
                camera = nil
                localCameraTrack = nil
                cameraTrack = nil
            }
            
            postChangeNotification()
        }
    }
    var participant: TwilioVideo.LocalParticipant? {
        didSet {
            participant?.delegate = self
        }
    }
    var localCameraTrack: TwilioVideo.LocalVideoTrack?
    private(set) var micTrack: LocalAudioTrack?
    private let notificationCenter = NotificationCenter.default

    init(identity: String) {
        self.identity = identity
    }
    
    private func postChangeNotification() {
        notificationCenter.post(name: .localParticipantDidChange, object: self)
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

extension LocalParticipant: CameraSourceDelegate {
    func cameraSourceWasInterrupted(source: CameraSource, reason: AVCaptureSession.InterruptionReason) {
        //        track.track.isEnabled = false
        //        sendUpdate()
    }

    func cameraSourceInterruptionEnded(source: CameraSource) {
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
