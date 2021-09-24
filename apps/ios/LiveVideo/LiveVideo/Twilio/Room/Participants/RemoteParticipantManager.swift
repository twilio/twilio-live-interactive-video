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
    var isMicOn: Bool {
        guard let micTrack = participant.remoteAudioTracks.first else { return false }
        
        return micTrack.isTrackSubscribed && micTrack.isTrackEnabled
    }
    var cameraTrack: VideoTrack? {
        guard
            let publication = participant.remoteVideoTracks.first(where: { $0.trackName.contains(TrackName.camera) }),
            let track = publication.remoteTrack,
            track.isEnabled
        else {
            return nil
        }
        
        return RemoteVideoTrack(track: track)
    }
    var isDominantSpeaker = false {
        didSet {
            dominantSpeakerTimestame = Date() // Date.now in iOS 15
            postRemoteParticipantDidChangeNotification()
        }
    }
    var dominantSpeakerTimestame: Date = .distantPast
    private let participant: RemoteParticipant
    private let notificationCenter = NotificationCenter.default
    
    init(participant: RemoteParticipant) {
        self.participant = participant
        super.init()
        participant.delegate = self
    }

    private func postRemoteParticipantDidChangeNotification() {
        notificationCenter.post(name: .remoteParticpantDidChange, object: self)
    }
}

extension RoomRemoteParticipant: RemoteParticipantDelegate {
    func didSubscribeToVideoTrack(
        videoTrack: TwilioVideo.RemoteVideoTrack,
        publication: RemoteVideoTrackPublication,
        participant: RemoteParticipant
    ) {
        postRemoteParticipantDidChangeNotification()
    }
    
    func didUnsubscribeFromVideoTrack(
        videoTrack: TwilioVideo.RemoteVideoTrack,
        publication: RemoteVideoTrackPublication,
        participant: RemoteParticipant
    ) {
        postRemoteParticipantDidChangeNotification()
    }

    func remoteParticipantDidEnableVideoTrack(
        participant: RemoteParticipant,
        publication: RemoteVideoTrackPublication
    ) {
        postRemoteParticipantDidChangeNotification()
    }
    
    func remoteParticipantDidDisableVideoTrack(
        participant: RemoteParticipant,
        publication: RemoteVideoTrackPublication
    ) {
        postRemoteParticipantDidChangeNotification()
    }

    func didSubscribeToAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: RemoteParticipant
    ) {
        postRemoteParticipantDidChangeNotification()
    }
    
    func didUnsubscribeFromAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: RemoteParticipant
    ) {
        postRemoteParticipantDidChangeNotification()
    }

    func remoteParticipantDidEnableAudioTrack(
        participant: RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        postRemoteParticipantDidChangeNotification()
    }
    
    func remoteParticipantDidDisableAudioTrack(
        participant: RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        postRemoteParticipantDidChangeNotification()
    }
}
