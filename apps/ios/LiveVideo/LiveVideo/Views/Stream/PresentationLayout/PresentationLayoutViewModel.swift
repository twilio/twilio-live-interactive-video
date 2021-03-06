//
//  Copyright (C) 2022 Twilio, Inc.
//

import TwilioVideo
import Combine

class PresentationLayoutViewModel: ObservableObject {
    struct Presenter {
        var identity: String = ""
        var displayName: String = ""
        var presentationTrack: VideoTrack?
    }

    @Published var isPresenting = false
    @Published var presenter = Presenter()
    @Published var dominantSpeaker = SpeakerVideoViewModel()
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
        guard let presenter = findPresenter() else {
            isPresenting = false
            presenter = Presenter()
            dominantSpeaker = SpeakerVideoViewModel()
            return
        }

        isPresenting = true
        self.presenter = presenter
        dominantSpeaker = findDominantSpeaker()
        dominantSpeaker.isDominantSpeaker = false // No need to distinguish in the UI since only 1 speaker is shown
    }
    
    private func findPresenter() -> Presenter? {
        guard let presenter = roomManager.remoteParticipants.first(where: { $0.presentationTrack != nil }) else {
            return nil
        }
        
        let isHost = speakersMap.host?.identity == presenter.identity
        
        return Presenter(
            identity: presenter.identity,
            displayName: DisplayNameFactory().makeDisplayName(identity: presenter.identity, isHost: isHost),
            presentationTrack: presenter.presentationTrack!
        )
    }
    
    private func findDominantSpeaker() -> SpeakerVideoViewModel {
        if let activeDominantSpeaker = roomManager.remoteParticipants.first(where: { $0.isDominantSpeaker }) {
            // There is an active dominant speaker
            return speakerVideoViewModelFactory.makeSpeaker(participant: activeDominantSpeaker)
        } else if let previousDominantSpeaker = roomManager.remoteParticipants.first(where: { $0.identity == dominantSpeaker.identity }) {
            // The previous dominant speaker is still connected so use them
            return speakerVideoViewModelFactory.makeSpeaker(participant: previousDominantSpeaker)
        } else {
            // Dominant speaker is not yet known or the previous dominant speaker disconnected
            if let firstRemoteParticipant = roomManager.remoteParticipants.first {
                // Keep it simple and just use first remote participant, someone will start talking soon
                return speakerVideoViewModelFactory.makeSpeaker(participant: firstRemoteParticipant)
            } else {
                // Use local participant
                return speakerVideoViewModelFactory.makeSpeaker(participant: roomManager.localParticipant)
            }
        }
    }
}
