//
//  Copyright (C) 2022 Twilio, Inc.
//

import TwilioVideo
import Combine

struct PresenterViewModel {
    let identity: String
    let displayName: String
    var presentationTrack: VideoTrack
}

class PresentationViewModel: ObservableObject {
    @Published var dominantSpeaker: [SpeakerVideoViewModel] = []
//    @Published var presenter: PresenterViewModel?
    @Published var presenterIdentity: String?
    @Published var presenterDisplayName: String?
    @Published var presentationTrack: VideoTrack?
    private var roomManager: RoomManager!
    private var speakersMap: SyncUsersMap!
    private var subscriptions = Set<AnyCancellable>()

    func configure(roomManager: RoomManager, speakersMap: SyncUsersMap) {
        self.roomManager = roomManager
        self.speakersMap = speakersMap
        
        roomManager.roomConnectPublisher
            .sink { [weak self] in self?.update() }
            .store(in: &subscriptions)
        
        roomManager.roomDisconnectPublisher
            .sink { [weak self] _ in self?.update() }
            .store(in: &subscriptions)

        roomManager.remoteParticipantConnectPublisher
            .sink { [weak self] _ in self?.update() }
            .store(in: &subscriptions)

        roomManager.remoteParticipantDisconnectPublisher
            .sink { [weak self] _ in self?.update() }
            .store(in: &subscriptions)

        roomManager.remoteParticipantChangePublisher
            .sink { [weak self] _ in self?.update() }
            .store(in: &subscriptions)
    }

    private func update() {
        guard let newPresenter = findPresenter() else {
            presenterIdentity = nil
            presenterDisplayName = nil
            presentationTrack = nil
            dominantSpeaker = []
            return
        }

        if newPresenter.identity != presenterIdentity {
            presenterIdentity = newPresenter.identity
            presenterDisplayName = newPresenter.displayName
            presentationTrack = newPresenter.presentationTrack
        }
        
        // Dominant speaker
        let dominantSpeaker = findDominantSpeaker()
        
        if !self.dominantSpeaker.isEmpty { //}  let currentDominantSpeaker = self.dominantSpeaker.first {
//            if dominantSpeaker.identity != currentDominantSpeaker.identity {
                self.dominantSpeaker[0] = dominantSpeaker
//            }
        } else {
            self.dominantSpeaker.append(dominantSpeaker)
        }
    }
    
    private func findPresenter() -> PresenterViewModel? {
        guard let presenter = roomManager.remoteParticipants.first(where: { $0.presentationTrack != nil }) else {
            return nil
        }
        
        let isHost = speakersMap.host?.identity == presenter.identity
        
        return PresenterViewModel(
            identity: presenter.identity,
            displayName: isHost ? "\(presenter.identity) (Host)" : presenter.identity,
            presentationTrack: presenter.presentationTrack!
        )
    }
    
    private func findDominantSpeaker() -> SpeakerVideoViewModel {
        // Show last dominant speaker
        if let dominantSpeaker = roomManager.remoteParticipants.first(where: { $0.isDominantSpeaker }) {
            return makeSpeaker(participant: dominantSpeaker)
        } else if let dominantSpeaker = dominantSpeaker.first, roomManager.remoteParticipants.first(where: { $0.identity == dominantSpeaker.identity }) != nil {
            return dominantSpeaker
        } else if let firstRemoteParticipant = roomManager.remoteParticipants.first {
            return makeSpeaker(participant: firstRemoteParticipant)
        } else {
            return makeSpeaker(participant: roomManager.localParticipant)
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
