//
//  Copyright (C) 2021 Twilio, Inc.
//

import TwilioVideo
import Combine

class SpeakerStore: NSObject, ObservableObject {
    @Published var speakers: [Speaker] = []
    
    func addRemoteParticipant(_ participant: TwilioVideo.RemoteParticipant) {
        participant.delegate = self
        
        let speaker = Speaker(identity: participant.identity, isMuted: participant.isMuted)
        
        speakers.append(speaker)
    }
    
    func removeRemoteParticipant(_ participant: TwilioVideo.RemoteParticipant) {
        speakers.removeAll { $0.identity == participant.identity }
    }
    
    func removeAll() {
        speakers.removeAll()
    }
    
    private func updateMuteForParticipant(_ participant: TwilioVideo.RemoteParticipant) {
        guard let speakerIndex = speakers.index(of: participant) else { return }

        speakers[speakerIndex].isMuted = participant.isMuted
    }
}

extension SpeakerStore: TwilioVideo.RemoteParticipantDelegate {
    func didSubscribeToVideoTrack(
        videoTrack: TwilioVideo.RemoteVideoTrack,
        publication: RemoteVideoTrackPublication,
        participant: TwilioVideo.RemoteParticipant
    ) {
        guard let source = videoTrack.source, let speakerIndex = speakers.index(of: participant) else { return }

        switch source {
        case .camera:
            speakers[speakerIndex].cameraTrack = RemoteVideoTrack(track: videoTrack)
        case .screen:
            break // Implement later
        }
    }
    
    func didUnsubscribeFromVideoTrack(
        videoTrack: TwilioVideo.RemoteVideoTrack,
        publication: RemoteVideoTrackPublication,
        participant: TwilioVideo.RemoteParticipant
    ) {
        guard let source = videoTrack.source, let speakerIndex = speakers.index(of: participant) else { return }

        switch source {
        case .camera:
            speakers[speakerIndex].cameraTrack = nil
        case .screen:
            break // Implement later
        }
    }
    
    func remoteParticipantDidEnableAudioTrack(
        participant: TwilioVideo.RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        updateMuteForParticipant(participant)
    }
    
    func remoteParticipantDidDisableAudioTrack(
        participant: TwilioVideo.RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        updateMuteForParticipant(participant)
    }
    
    func didSubscribeToAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: TwilioVideo.RemoteParticipant
    ) {
        updateMuteForParticipant(participant)
    }
    
    func didUnsubscribeFromAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: TwilioVideo.RemoteParticipant
    ) {
        updateMuteForParticipant(participant)
    }
}

private extension TwilioVideo.RemoteVideoTrack {
    var source: VideoSource? { VideoSource(trackName: name) }
}

private extension Array where Element == Speaker {
    func index(of participant: TwilioVideo.RemoteParticipant) -> Int? {
        firstIndex { $0.identity == participant.identity }
    }
}



struct Speaker: Hashable {
    let identity: String
    var cameraTrack: VideoTrack? = nil
    var isMuted: Bool
    
    static func == (lhs: Speaker, rhs: Speaker) -> Bool {
        lhs.identity == rhs.identity
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(identity)
    }
}

private extension TwilioVideo.RemoteParticipant {
    var isMuted: Bool {
        guard let micTrack = remoteAudioTracks.first else { return true }
        
        return !micTrack.isTrackSubscribed || !micTrack.isTrackEnabled
    }
}
