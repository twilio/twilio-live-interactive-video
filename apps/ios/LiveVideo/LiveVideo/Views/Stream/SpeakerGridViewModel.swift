//
//  Copyright (C) 2021 Twilio, Inc.
//

import TwilioVideo
import Combine

/// Subscribes to room and participant state changes to provide speaker state for the UI to display in a grid
class SpeakerGridViewModel: ObservableObject {
    /// The speakers that the UI should display.
    @Published var speakers: [SpeakerVideoViewModel] = []
    
    private let maxSpeakerCount = 6
    private let notificationCenter = NotificationCenter.default
    
    /// The speakers that the UI should not display.
    private var offscreen: [SpeakerVideoViewModel] = []
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
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
        if speakers.count < maxSpeakerCount {
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
        if let index = speakers.firstIndex(of: speaker) {
            speakers[index] = speaker
        } else if let index = offscreen.firstIndex(of: speaker) {
            offscreen[index] = speaker

            // If an offscreen speaker becomes dominant speaker move them to onscreen speakers.
            // The oldest dominant speaker that is onscreen is moved to the start of offscreen users.
            // The new dominant speaker is moved onscreen where the oldest dominant speaker was located.
            // This approach always keeps the most recent dominant speakers visible.
            if speaker.isDominantSpeaker {
                let oldestDominantSpeaker = speakers[1...] // Skip local user at 0
                    .sorted { $0.dominantSpeakerStartTime < $1.dominantSpeakerStartTime }
                    .first!
                
                let oldestDominantSpeakerIndex = speakers.firstIndex(of: oldestDominantSpeaker)!
                
                speakers.remove(at: oldestDominantSpeakerIndex)
                speakers.insert(speaker, at: oldestDominantSpeakerIndex)
                offscreen.remove(at: index)
                offscreen.insert(oldestDominantSpeaker, at: 0)
            }
        }
    }
}
