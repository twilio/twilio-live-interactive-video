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

class LocalParticipantManager: NSObject {
    let identity: String
    var isMicOn: Bool {
        get {
            micTrack?.isEnabled ?? false
        }
        set {
            if newValue {
                guard
                    micTrack == nil,
                    let micTrack = LocalAudioTrack(options: nil, enabled: true, name: TrackName.mic)
                else {
                    return
                }
                
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
    var isCameraOn = false {
        didSet {
            guard oldValue != isCameraOn else { return }
            
            if isCameraOn {
                let sourceOptions = CameraSourceOptions { builder in
                    guard let scene = self.app.windows.filter({ $0.isKeyWindow }).first?.windowScene else { return }
                    
                    builder.orientationTracker = UserInterfaceTracker(scene: scene)
                }
                
                guard
                    let cameraSource = CameraSource(options: sourceOptions, delegate: self),
                    let captureDevice = CameraSource.captureDevice(position: .front),
                    let cameraTrack = LocalVideoTrack(source: cameraSource, enabled: true, name: TrackName.camera)
                else {
                    return
                }
                
                cameraSource.startCapture(device: captureDevice) { _, _, error in
                    if let error = error {
                        print("Start capture error: \(error)")
                    }
                }

                participant?.publishVideoTrack(cameraTrack)
                self.cameraSource = cameraSource
                self.cameraTrack = cameraTrack
            } else {
                if let cameraTrack = cameraTrack {
                    participant?.unpublishVideoTrack(cameraTrack)
                }
                
                cameraSource?.stopCapture()
                cameraSource = nil
                cameraTrack = nil
            }
            
            postChangeNotification()
        }
    }
    var participant: LocalParticipant? {
        didSet {
            participant?.delegate = self
        }
    }
    private(set) var micTrack: LocalAudioTrack?
    private(set) var cameraTrack: LocalVideoTrack?
    private let notificationCenter = NotificationCenter.default
    private let app = UIApplication.shared
    private var cameraSource: CameraSource?

    init(identity: String) {
        self.identity = identity
    }
    
    private func postChangeNotification() {
        notificationCenter.post(name: .localParticipantDidChange, object: self)
    }
}

extension LocalParticipantManager: LocalParticipantDelegate {
    func localParticipantDidFailToPublishVideoTrack(
        participant: LocalParticipant,
        videoTrack: LocalVideoTrack,
        error: Error
    ) {
        print("Failed to publish video track: \(error)")
    }
    
    func localParticipantDidFailToPublishAudioTrack(
        participant: LocalParticipant,
        audioTrack: LocalAudioTrack,
        error: Error
    ) {
        print("Failed to publish audio track: \(error)")
    }
}

extension LocalParticipantManager: CameraSourceDelegate {
    func cameraSourceWasInterrupted(source: CameraSource, reason: AVCaptureSession.InterruptionReason) {
        cameraTrack?.isEnabled = false
        postChangeNotification()
    }

    func cameraSourceInterruptionEnded(source: CameraSource) {
        cameraTrack?.isEnabled = true
        postChangeNotification()
    }
}
