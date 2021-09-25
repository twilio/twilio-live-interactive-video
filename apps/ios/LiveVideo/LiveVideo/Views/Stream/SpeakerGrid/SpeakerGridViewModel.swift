//
//  Copyright (C) 2021 Twilio, Inc.
//

import TwilioVideo
import Combine

class SpeakerGridViewModel: ObservableObject {
    @Published var speakers: [SpeakerVideoViewModel] = []
    private var offscreen: [SpeakerVideoViewModel] = []
    private var subscriptions = Set<AnyCancellable>()

    init() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.publisher(for: .roomDidConnect)
            .map { $0.object as! RoomManager }
            .sink { [weak self] roomManager in
                self?.addSpeaker(SpeakerVideoViewModel(participant: roomManager.localParticipant))

                roomManager.remoteParticipants
                    .map { SpeakerVideoViewModel(participant: $0) }
                    .forEach { self?.addSpeaker($0) }
            }
            .store(in: &subscriptions)
        
        notificationCenter.publisher(for: .roomDidDisconnectWithError)
            .sink { [weak self] _ in self?.speakers.removeAll() }
            .store(in: &subscriptions)

        notificationCenter.publisher(for: .localParticipantDidChange)
            .map { $0.object as! LocalParticipantManager }
            .sink { [weak self] participant in
                guard let self = self, !self.speakers.isEmpty else { return }
                
                self.speakers[0] = SpeakerVideoViewModel(participant: participant)
            }
            .store(in: &subscriptions)

        notificationCenter.publisher(for: .remoteParticipantDidConnect)
            .map { $0.object as! RemoteParticipantManager }
            .sink { [weak self] participant in self?.addSpeaker(SpeakerVideoViewModel(participant: participant)) }
            .store(in: &subscriptions)

        notificationCenter.publisher(for: .remoteParticipantDidDisconnect)
            .map { $0.object as! RemoteParticipantManager }
            .sink { [weak self] participant in self?.removeSpeaker(with: participant.identity) }
            .store(in: &subscriptions)
        
        notificationCenter.publisher(for: .remoteParticipantDidChange)
            .map { $0.object as! RemoteParticipantManager }
            .sink { [weak self] participant in self?.updateSpeaker(SpeakerVideoViewModel(participant: participant)) }
            .store(in: &subscriptions)
    }
    
    private func addSpeaker(_ speaker: SpeakerVideoViewModel) {
        if speakers.count < 6 {
            speakers.append(speaker)
        } else {
            offscreen.append(speaker)
        }
    }
    
    private func removeSpeaker(with identity: String) {
        if let index = speakers.firstIndex(where: { $0.identity == identity }) {
            speakers.remove(at: index)
            
            if !offscreen.isEmpty {
                speakers.append(offscreen.removeFirst())
            }
        } else {
            offscreen.removeAll { $0.identity == identity }
        }
    }
    
    private func updateSpeaker(_ speaker: SpeakerVideoViewModel) {
        // Find and replace
        if let speakerIndex = speakers.firstIndex(where: { $0.identity == speaker.identity }) {
            speakers[speakerIndex] = speaker
        } else if let speakerIndex = offscreen.firstIndex(where: { $0.identity == speaker.identity }) {
            offscreen[speakerIndex] = speaker
            
            if speaker.isDominantSpeaker {
                // Find oldest dominant speaker
                let sortedSpeakers = speakers[1...].sorted { $0.dominantSpeakerStartTime < $1.dominantSpeakerStartTime }
                
                let oldest = sortedSpeakers.first! // Don't bang
                // Move them offscreen
                
                let oldestIndex = speakers.firstIndex { $0.identity == oldest.identity }!
                
                speakers.remove(at: oldestIndex)
                
                // Move new dominant speaker onscreen
                speakers.insert(offscreen.remove(at: speakerIndex), at: oldestIndex)
                offscreen.insert(oldest, at: 0)
            }
        }
    }
}
