//
//  Copyright (C) 2021 Twilio, Inc.
//

import TwilioVideo
import Combine

class SpeakerStore: NSObject, ObservableObject {
    @Published var speakers: [Speaker] = []
    
    func addRemoteParticipant(_ participant: TwilioVideo.RemoteParticipant) {
        participant.delegate = self
        
        speakers.append(Speaker(identity: participant.identity))
    }
    
    func removeRemoteParticipant(_ participant: TwilioVideo.RemoteParticipant) {
        speakers.removeAll { $0.identity == participant.identity }
    }
    
    func removeAll() {
        speakers.removeAll()
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
            print("did set camera track: \(speakers)")
        case .screen:
            break
//            screenTrack = RemoteVideoTrack(track: videoTrack)
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
            print("did clear camera track: \(speakers)")
        case .screen:
            break
//            screenTrack = nil
        }
    }
    
    func remoteParticipantDidEnableAudioTrack(
        participant: TwilioVideo.RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        guard let speakerIndex = speakers.index(of: participant) else { return }

        
    }
    
    func remoteParticipantDidDisableAudioTrack(
        participant: TwilioVideo.RemoteParticipant,
        publication: RemoteAudioTrackPublication
    ) {
        
    }
    
    func didSubscribeToAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: TwilioVideo.RemoteParticipant
    ) {
        
    }
    
    func didUnsubscribeFromAudioTrack(
        audioTrack: RemoteAudioTrack,
        publication: RemoteAudioTrackPublication,
        participant: TwilioVideo.RemoteParticipant
    ) {
        
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
    
    static func == (lhs: Speaker, rhs: Speaker) -> Bool {
        lhs.identity == rhs.identity
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(identity)
    }
}
