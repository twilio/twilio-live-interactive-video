//
//  Copyright (C) 2021 Twilio, Inc.
//

import TwilioVideo
import Combine

class SpeakerStore: ObservableObject {
    @Published var speakers: [Speaker] = []
    private var offscreenSpeakers: [Speaker] = []
    private var subscriptions = Set<AnyCancellable>()
    var roomManager: RoomManager!

    init() {
        let notificationCenter = NotificationCenter.default
        
        // TODO: Need weak self?
        notificationCenter.publisher(for: .roomDidConnect)
            .map { $0.object as! RoomManager }
            .sink {
                self.addSpeaker(Speaker(localParticipant: self.roomManager.localParticipant))

                $0.remoteParticipants.map { Speaker(remoteParticipant: $0) }.forEach { self.addSpeaker($0) }
            }
            .store(in: &subscriptions)
        
        notificationCenter.publisher(for: .roomDidDisconnect)
            .sink { _ in self.speakers.removeAll() }
            .store(in: &subscriptions)

        notificationCenter.publisher(for: .remoteParticipantDidConnect)
            .map { Speaker(remoteParticipant: $0.object as! RoomRemoteParticipant) }
            .sink { self.addSpeaker($0) }
            .store(in: &subscriptions)

        notificationCenter.publisher(for: .remoteParticipantDidDisconnect)
            .map { $0.object as! RoomRemoteParticipant }
            .sink { self.removeSpeaker($0) }
            .store(in: &subscriptions)
        
        notificationCenter.publisher(for: .localParticipantDidChange)
            .map { $0.object as! LocalParticipant }
            .sink {
                guard !self.speakers.isEmpty else { return }
                
                self.speakers[0] = Speaker(localParticipant: $0)
            }
            .store(in: &subscriptions)

        notificationCenter.publisher(for: .remoteParticpantDidChange)
            .map { Speaker(remoteParticipant: $0.object as! RoomRemoteParticipant) }
            .sink { self.updateSpeaker($0) }
            .store(in: &subscriptions)
    }
    
    private func addSpeaker(_ speaker: Speaker) {
        if speakers.count < 6 {
            speakers.append(speaker)
        } else {
            offscreenSpeakers.append(speaker)
        }
    }
    
    private func removeSpeaker(_ remoteParticipant: RoomRemoteParticipant) {
        if let index = self.speakers.firstIndex(where: { $0.identity == remoteParticipant.identity }) {
            self.speakers.remove(at: index)
            
            if !self.offscreenSpeakers.isEmpty {
                self.speakers.append(self.offscreenSpeakers.removeFirst())
            }
        } else {
            self.offscreenSpeakers.removeAll { $0.identity == remoteParticipant.identity }
        }
    }
    
    private func updateSpeaker(_ speaker: Speaker) {
        // Find and replace
        if let speakerIndex = speakers.firstIndex(where: { $0.identity == speaker.identity }) {
            speakers[speakerIndex] = speaker
        } else if let speakerIndex = offscreenSpeakers.firstIndex(where: { $0.identity == speaker.identity }) {
            offscreenSpeakers[speakerIndex] = speaker
            
            if speaker.isDominantSpeaker {
                // Find oldest dominant speaker
                let sortedSpeakers = speakers[1...].sorted { $0.dominantSpeakerTimestamp < $1.dominantSpeakerTimestamp }
                
                let oldest = sortedSpeakers.first! // Don't bang
                // Move them offscreen
                
                let oldestIndex = speakers.firstIndex { $0.identity == oldest.identity }!
                
                speakers.remove(at: oldestIndex)
                
                // Move new dominant speaker onscreen
                speakers.insert(offscreenSpeakers.remove(at: speakerIndex), at: oldestIndex)
                offscreenSpeakers.insert(oldest, at: 0)
            }
        }
    }
}
