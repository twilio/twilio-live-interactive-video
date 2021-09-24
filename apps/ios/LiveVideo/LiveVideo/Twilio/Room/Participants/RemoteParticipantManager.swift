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

class RemoteParticipantManager: NSObject {
    var identity: String { participant.identity }
    var isMicOn: Bool {
        guard let track = participant.remoteAudioTracks.first else { return false }
        
        return track.isTrackSubscribed && track.isTrackEnabled
    }
    var cameraTrack: VideoTrack? {
        guard
            let publication = participant.remoteVideoTracks.first(where: { $0.trackName.contains(TrackName.camera) }),
            let track = publication.remoteTrack,
            track.isEnabled
        else {
            return nil
        }
        
        return track
    }
    var isDominantSpeaker = false {
        didSet {
            dominantSpeakerStartTime = Date()
            postChangeNotification()
        }
    }
    var dominantSpeakerStartTime: Date = .distantPast
    private let participant: RemoteParticipant
    private let notificationCenter = NotificationCenter.default
    
    init(participant: RemoteParticipant) {
        self.participant = participant
        super.init()
        participant.delegate = self
    }

    private func postChangeNotification() {
        notificationCenter.post(name: .remoteParticpantDidChange, object: self)
    }
}

extension RemoteParticipantManager: RemoteParticipantDelegate {
    func didSubscribeToVideoTrack(
        videoTrack: RemoteVideoTrack,
        publication: RemoteVideoTrackPublication,
        participant: RemoteParticipant
    ) {
        postChangeNotification()
    }
    
    func didUnsubscribeFromVideoTrack(
        videoTrack: RemoteVideoTrack,
        publication: RemoteVideoTrackPublication,
        participant: RemoteParticipant
    ) {
        postChangeNotification()
    }

    func remoteParticipantDidEnableVideoTrack(
        participant: RemoteParticipant,
        publication: RemoteVideoTrackPublication
    ) {
        postChangeNotification()
    }
    
    func remoteParticipantDidDisableVideoTrack(
        participant: RemoteParticipant,
        publication: RemoteVideoTrackPublication
    ) {
        postChangeNotification()
    }

    func didSubscribeToAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: RemoteParticipant
    ) {
        postChangeNotification()
    }
    
    func didUnsubscribeFromAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: RemoteParticipant
    ) {
        postChangeNotification()
    }

    func remoteParticipantDidEnableAudioTrack(
        participant: RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        postChangeNotification()
    }
    
    func remoteParticipantDidDisableAudioTrack(
        participant: RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        postChangeNotification()
    }
}
