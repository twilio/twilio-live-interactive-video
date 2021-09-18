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

class RoomRemoteParticipant: NSObject {
    var identity: String { participant.identity }
    var isDominantSpeaker = false
    private(set) var isMicOn = false {
        didSet {
            notificationCenter.post(name: .remoteParticipantDidChangeMic, object: self)
        }
    }
    private(set) var cameraTrack: VideoTrack? {
        didSet {
            notificationCenter.post(name: .remoteParticipantDidChangeCameraTrack, object: self)
        }
    }
    private let participant: RemoteParticipant
    private let notificationCenter = NotificationCenter.default
    
    init(participant: RemoteParticipant) {
        self.participant = participant
        super.init()
        participant.delegate = self
        updateMic()
        updateVideoTracks()
    }
    
    private func updateVideoTracks() {
        cameraTrack = participant.cameraTrack
        print("cameraTrack: \(cameraTrack)")
    }
    
    private func updateMic() {
        isMicOn = participant.isMicOn
    }
}

// Not a lot of activity so to keep this code simple just update everything
extension RoomRemoteParticipant: RemoteParticipantDelegate {
    func remoteParticipantDidEnableVideoTrack(
        participant: RemoteParticipant,
        publication: RemoteVideoTrackPublication
    ) {
        updateVideoTracks()
    }
    
    func remoteParticipantDidDisableVideoTrack(
        participant: RemoteParticipant,
        publication: RemoteVideoTrackPublication
    ) {
        updateVideoTracks()
    }
    
    // TODO: Add UX for track switch off?
    func didSubscribeToVideoTrack(
        videoTrack: TwilioVideo.RemoteVideoTrack,
        publication: RemoteVideoTrackPublication,
        participant: RemoteParticipant
    ) {
        updateVideoTracks()
    }
    
    func didUnsubscribeFromVideoTrack(
        videoTrack: TwilioVideo.RemoteVideoTrack,
        publication: RemoteVideoTrackPublication,
        participant: RemoteParticipant
    ) {
        updateVideoTracks()
    }
        
    func remoteParticipantDidEnableAudioTrack(
        participant: RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        updateMic()
    }
    
    func remoteParticipantDidDisableAudioTrack(
        participant: RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        updateMic()
    }
    
    func didSubscribeToAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: RemoteParticipant
    ) {
        updateMic()
    }
    
    func didUnsubscribeFromAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: RemoteParticipant
    ) {
        updateMic()
    }
}

private extension RemoteParticipant {
    var isMicOn: Bool {
        guard let micTrack = remoteAudioTracks.first else { return false }
        
        return micTrack.isTrackSubscribed && micTrack.isTrackEnabled
    }
    
    var cameraTrack: VideoTrack? {
        guard
            // TODO: Refactor contains?
            let publication = remoteVideoTracks.first(where: { $0.trackName.contains(TrackName.camera) }),
            let track = publication.remoteTrack,
            track.isEnabled
        else {
            return nil
        }
        
        return RemoteVideoTrack(track: track)
    }
}
