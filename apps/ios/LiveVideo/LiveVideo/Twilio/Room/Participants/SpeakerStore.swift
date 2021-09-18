//
//  Copyright (C) 2021 Twilio, Inc.
//

import TwilioVideo
import Combine

class SpeakerStore: ObservableObject {
    @Published var speakers: [Speaker] = []
    private var subscriptions = Set<AnyCancellable>()
    var roomManager: RoomManager!

    init() {
        let notificationCenter = NotificationCenter.default
        
        // TODO: Need weak self?
        notificationCenter.publisher(for: .roomDidConnect)
            .sink() { _ in
                self.speakers.append(Speaker(localParticipant: self.roomManager.localParticipant))
                self.roomManager.remoteParticipants.forEach { self.speakers.append(Speaker(remoteParticipant: $0)) }
            }
            .store(in: &subscriptions)
        
        notificationCenter.publisher(for: .roomDidDisconnect)
            .sink() { _ in
                self.speakers.removeAll()
            }
            .store(in: &subscriptions)

        notificationCenter.publisher(for: .remoteParticipantDidConnect)
            .sink() { notification in
                guard let remoteParticipant = notification.object as? RoomRemoteParticipant else { return }
                
                self.speakers.append(Speaker(remoteParticipant: remoteParticipant))
            }
            .store(in: &subscriptions)

        notificationCenter.publisher(for: .remoteParticipantDidDisconnect)
            .sink() { notification in
                guard let remoteParticipant = notification.object as? RoomRemoteParticipant else { return }
                
                self.speakers.removeAll { $0.identity == remoteParticipant.identity }
            }
            .store(in: &subscriptions)
        
        notificationCenter.publisher(for: .localParticipantDidChangeMic)
            .sink() { _ in
                guard !self.speakers.isEmpty else { return }
                
                self.speakers[0].isMuted = !self.roomManager.localParticipant.isMicOn
            }
            .store(in: &subscriptions)

        notificationCenter.publisher(for: .localParticipantDidChangeCameraTrack)
            .sink() { _ in
                guard !self.speakers.isEmpty else { return }

                self.speakers[0].cameraTrack = self.roomManager.localParticipant.cameraTrack
            }
            .store(in: &subscriptions)

        notificationCenter.publisher(for: .remoteParticipantDidChangeMic)
            .sink() { notification in
                guard
                    let remoteParticipant = notification.object as? RoomRemoteParticipant,
                    let speakerIndex = self.speakers.index(of: remoteParticipant)
                else {
                    return
                }
                
                self.speakers[speakerIndex].isMuted = !remoteParticipant.isMicOn
            }
            .store(in: &subscriptions)

        notificationCenter.publisher(for: .remoteParticipantDidChangeDominantSpeaker)
            .sink() { notification in
                guard
                    let remoteParticipant = notification.object as? RoomRemoteParticipant,
                    let speakerIndex = self.speakers.index(of: remoteParticipant)
                else {
                    return
                }
                
                self.speakers[speakerIndex].isDominantSpeaker = remoteParticipant.isDominantSpeaker
            }
            .store(in: &subscriptions)

        notificationCenter.publisher(for: .remoteParticipantDidChangeCameraTrack)
            .sink() { notification in
                print("camera notification received")
                
                guard
                    let remoteParticipant = notification.object as? RoomRemoteParticipant,
                    let speakerIndex = self.speakers.index(of: remoteParticipant)
                else {
                    return
                }
                print("camera track set")

                self.speakers[speakerIndex].cameraTrack = remoteParticipant.cameraTrack
            }
            .store(in: &subscriptions)
    }
}

private extension Array where Element == Speaker {
    func index(of participant: RoomRemoteParticipant) -> Int? {
        firstIndex { $0.identity == participant.identity }
    }
}
