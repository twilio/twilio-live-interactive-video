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

class RoomRemoteParticipant: NSObject {
    var identity: String { participant.identity }
    @Published var isDominantSpeaker = false
    @Published private(set) var isMicOn = false
    @Published private(set) var cameraTrack: VideoTrack?
    private let participant: RemoteParticipant
    
    init(participant: RemoteParticipant) {
        self.participant = participant
        super.init()
        participant.delegate = self
        updateMic()
        updateVideoTracks()
    }
    
    private func updateVideoTracks() {
        cameraTrack = participant.cameraTrack
    }
    
    private func updateMic() {
        isMicOn = participant.isMicOn
    }
}

extension RoomRemoteParticipant: RemoteParticipantDelegate {
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
}

private extension RemoteParticipant {
    var isMicOn: Bool {
        guard let micTrack = remoteAudioTracks.first else { return false }
        
        return micTrack.isTrackSubscribed && micTrack.isTrackEnabled
    }
    
    var cameraTrack: VideoTrack? {
        guard
            let publication = remoteVideoTracks.first(where: { $0.trackName.contains(TrackName.camera) }),
            let track = publication.remoteTrack,
            track.isEnabled
        else {
            return nil
        }
        
        return RemoteVideoTrack(track: track)
    }
}
