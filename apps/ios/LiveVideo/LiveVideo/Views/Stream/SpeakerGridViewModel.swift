//
//  Copyright (C) 2021 Twilio, Inc.
//

import TwilioVideo
import Combine

/// Subscribes to room and participant state changes to provide speaker state for the UI to display in a grid
class SpeakerGridViewModel: ObservableObject {
    struct Page: Hashable {
        let identifier: Int
        var speakers: [SpeakerVideoViewModel]
        
        func indexOf(identity: String) -> Int? {
            speakers.firstIndex { $0.identity == identity }
        }

        static func == (lhs: Page, rhs: Page) -> Bool {
            lhs.identifier == rhs.identifier
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }
    
    @Published var pages: [Page] = []
    @Published var selectedPage = 0 {
        didSet {
            print("Selected page: \(selectedPage)")
        }
    }

    

    @Published var onscreenSpeakers: [SpeakerVideoViewModel] = []
    @Published var offscreenSpeakers: [SpeakerVideoViewModel] = []
    private let maxOnscreenSpeakerCount = 6
    private var roomManager: RoomManager!
    private var speakersMap: SyncUsersMap!
    private var speakerVideoViewModelFactory: SpeakerVideoViewModelFactory!
    private var subscriptions = Set<AnyCancellable>()

    func configure(
        roomManager: RoomManager,
        speakersMap: SyncUsersMap,
        speakerVideoViewModelFactory: SpeakerVideoViewModelFactory
    ) {
        self.roomManager = roomManager
        self.speakersMap = speakersMap
        self.speakerVideoViewModelFactory = speakerVideoViewModelFactory
        
        roomManager.roomConnectPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                
                self.addSpeaker(self.speakerVideoViewModelFactory.makeSpeaker(participant: self.roomManager.localParticipant))

                self.roomManager.remoteParticipants
                    .map { self.speakerVideoViewModelFactory.makeSpeaker(participant: $0) }
                    .forEach { self.addSpeaker($0) }
            }
            .store(in: &subscriptions)
        
        roomManager.roomDisconnectPublisher
            .sink { [weak self] _ in
                self?.onscreenSpeakers.removeAll()
                self?.offscreenSpeakers.removeAll()
            }
            .store(in: &subscriptions)

        roomManager.localParticipant.changePublisher
            .sink { [weak self] participant in
                guard let self = self, !self.onscreenSpeakers.isEmpty else { return }
                
                self.onscreenSpeakers[0] = self.speakerVideoViewModelFactory.makeSpeaker(participant: participant)
            }
            .store(in: &subscriptions)

        roomManager.remoteParticipantConnectPublisher
            .sink { [weak self] participant in
                guard let self = self else { return }

                self.addSpeaker(self.speakerVideoViewModelFactory.makeSpeaker(participant: participant)) }
            .store(in: &subscriptions)

        roomManager.remoteParticipantDisconnectPublisher
            .sink { [weak self] participant in self?.removeSpeaker(with: participant.identity) }
            .store(in: &subscriptions)

        roomManager.remoteParticipantChangePublisher
            .sink { [weak self] participant in
                guard let self = self else { return }

                self.updateSpeaker(self.speakerVideoViewModelFactory.makeSpeaker(participant: participant)) }
            .store(in: &subscriptions)
    }
    
    private func addSpeaker(_ speaker: SpeakerVideoViewModel) {
        if !pages.isEmpty && pages.last!.speakers.count < maxOnscreenSpeakerCount {
            pages[pages.count - 1].speakers.append(speaker)
        } else {
            let newPage = Page(identifier: pages.count, speakers: [speaker])
            pages.append(newPage)
        }
    }
    
    private func removeSpeaker(with identity: String) {

        
        
        
        
        
        
//        if let index = onscreenSpeakers.firstIndex(where: { $0.identity == identity }) {
//            onscreenSpeakers.remove(at: index)
//
//            if !offscreenSpeakers.isEmpty {
//                onscreenSpeakers.append(offscreenSpeakers.removeFirst())
//            }
//        } else {
//            offscreenSpeakers.removeAll { $0.identity == identity }
//        }
    }

    private func pageIndexForSpeaker(identity: String) -> Int? {
        pages.firstIndex { $0.indexOf(identity: identity) != nil }
    }
    
    private func updateSpeaker(_ speaker: SpeakerVideoViewModel) {
        guard
            let pageIndex = pageIndexForSpeaker(identity: speaker.identity),
            let speakerIndex = pages[pageIndex].indexOf(identity: speaker.identity)
        else {
            return
        }
        
        pages[pageIndex].speakers[speakerIndex] = speaker
        
        
        
        
//        guard let index = pages.firstIndex(where: { $0.speaker.identity == speaker.identity }) else {
//            return
//        }
//
//        pages[index].speaker = speaker
        

        
        
        
        
        
        
        
//        if let index = onscreenSpeakers.firstIndex(of: speaker) {
//            onscreenSpeakers[index] = speaker
//        } else if let index = offscreenSpeakers.firstIndex(of: speaker) {
//            offscreenSpeakers[index] = speaker
//
//            // If an offscreen speaker becomes dominant speaker move them to onscreen speakers.
//            // The oldest dominant speaker that is onscreen is moved to the start of offscreen users.
//            // The new dominant speaker is moved onscreen where the oldest dominant speaker was located.
//            // This approach always keeps the most recent dominant speakers visible.
//            if speaker.isDominantSpeaker {
//                let oldestDominantSpeaker = onscreenSpeakers[1...] // Skip local user at 0
//                    .sorted { $0.dominantSpeakerStartTime < $1.dominantSpeakerStartTime }
//                    .first!
//
//                let oldestDominantSpeakerIndex = onscreenSpeakers.firstIndex(of: oldestDominantSpeaker)!
//
//                onscreenSpeakers.remove(at: oldestDominantSpeakerIndex)
//                onscreenSpeakers.insert(speaker, at: oldestDominantSpeakerIndex)
//                offscreenSpeakers.remove(at: index)
//                offscreenSpeakers.insert(oldestDominantSpeaker, at: 0)
//            }
//        }
    }
}
