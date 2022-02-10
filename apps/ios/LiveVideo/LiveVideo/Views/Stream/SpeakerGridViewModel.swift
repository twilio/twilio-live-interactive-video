//
//  Copyright (C) 2021 Twilio, Inc.
//

import TwilioVideo
import Combine

/// Subscribes to room and participant state changes to provide speaker state for the UI to display in a grid
class SpeakerGridViewModel: ObservableObject {
    @Published var onscreenSpeakers: [SpeakerVideoViewModel] = []
    @Published var offscreenSpeakers: [SpeakerVideoViewModel] = []
    private let maxOnscreenSpeakerCount = 6
    private var roomManager: RoomManager!
    private var speakersMap: SyncUsersMap!
    private var api: API!
    private var subscriptions = Set<AnyCancellable>()

    func configure(roomManager: RoomManager, speakersMap: SyncUsersMap, api: API) {
        self.roomManager = roomManager
        self.speakersMap = speakersMap
        self.api = api
        
        roomManager.roomConnectPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                
                self.addSpeaker(self.makeSpeaker(participant: self.roomManager.localParticipant))

                self.roomManager.remoteParticipants
                    .map { self.makeSpeaker(participant: $0) }
                    .forEach { self.addSpeaker($0) }
            }
            .store(in: &subscriptions)
        
        roomManager.roomDisconnectPublisher
            .sink { [weak self] _ in self?.onscreenSpeakers.removeAll() } // Remove offscreen speakers?
            .store(in: &subscriptions)

        roomManager.localParticipant.changePublisher
            .sink { [weak self] participant in
                guard let self = self, !self.onscreenSpeakers.isEmpty else { return }
                
                self.onscreenSpeakers[0] = self.makeSpeaker(participant: participant)
            }
            .store(in: &subscriptions)

        roomManager.remoteParticipantConnectPublisher
            .sink { [weak self] participant in
                guard let self = self else { return }

                self.addSpeaker(self.makeSpeaker(participant: participant)) }
            .store(in: &subscriptions)

        roomManager.remoteParticipantDisconnectPublisher
            .sink { [weak self] participant in self?.removeSpeaker(with: participant.identity) }
            .store(in: &subscriptions)

        roomManager.remoteParticipantChangePublisher
            .sink { [weak self] participant in
                guard let self = self else { return }

                self.updateSpeaker(self.makeSpeaker(participant: participant)) }
            .store(in: &subscriptions)
    }

    func muteSpeaker(_ speaker: SpeakerVideoViewModel) {
        let message = RoomMessage(messageType: .mute, toParticipantIdentity: speaker.identity)
        roomManager.localParticipant.sendMessage(message)
    }

    func removeSpeaker(_ speaker: SpeakerVideoViewModel) {
        guard let roomName = roomManager.roomName else {
            return
        }
        
        let request = RemoveSpeakerRequest(roomName: roomName, userIdentity: speaker.identity)
        api.request(request)
    }
    
    private func addSpeaker(_ speaker: SpeakerVideoViewModel) {
        if onscreenSpeakers.count < maxOnscreenSpeakerCount {
            onscreenSpeakers.append(speaker)
        } else {
            offscreenSpeakers.append(speaker)
        }
    }
    
    private func removeSpeaker(with identity: String) {
        if let index = onscreenSpeakers.firstIndex(where: { $0.identity == identity }) {
            onscreenSpeakers.remove(at: index)
            
            if !offscreenSpeakers.isEmpty {
                onscreenSpeakers.append(offscreenSpeakers.removeFirst())
            }
        } else {
            offscreenSpeakers.removeAll { $0.identity == identity }
        }
    }

    private func updateSpeaker(_ speaker: SpeakerVideoViewModel) {
        if let index = onscreenSpeakers.firstIndex(of: speaker) {
            onscreenSpeakers[index] = speaker
        } else if let index = offscreenSpeakers.firstIndex(of: speaker) {
            offscreenSpeakers[index] = speaker

            // If an offscreen speaker becomes dominant speaker move them to onscreen speakers.
            // The oldest dominant speaker that is onscreen is moved to the start of offscreen users.
            // The new dominant speaker is moved onscreen where the oldest dominant speaker was located.
            // This approach always keeps the most recent dominant speakers visible.
            if speaker.isDominantSpeaker {
                let oldestDominantSpeaker = onscreenSpeakers[1...] // Skip local user at 0
                    .sorted { $0.dominantSpeakerStartTime < $1.dominantSpeakerStartTime }
                    .first!
                
                let oldestDominantSpeakerIndex = onscreenSpeakers.firstIndex(of: oldestDominantSpeaker)!
                
                onscreenSpeakers.remove(at: oldestDominantSpeakerIndex)
                onscreenSpeakers.insert(speaker, at: oldestDominantSpeakerIndex)
                offscreenSpeakers.remove(at: index)
                offscreenSpeakers.insert(oldestDominantSpeaker, at: 0)
            }
        }
    }
    
    private func makeSpeaker(participant: LocalParticipantManager) -> SpeakerVideoViewModel {
        let isHost = speakersMap.host?.identity == participant.identity
        return SpeakerVideoViewModel(participant: participant, isHost: isHost)
    }

    private func makeSpeaker(participant: RemoteParticipantManager) -> SpeakerVideoViewModel {
        let isHost = speakersMap.host?.identity == participant.identity
        return SpeakerVideoViewModel(participant: participant, isHost: isHost)
    }
}

private extension SyncUsersMap {
    var host: User? {
        users.first { $0.isHost } // This app only has one host and it is the user that created the stream
    }
}
