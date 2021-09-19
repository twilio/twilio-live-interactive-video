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
            .sink() { _ in
                self.speakers.append(Speaker(localParticipant: self.roomManager.localParticipant))
                
                self.roomManager.remoteParticipants[...min(4, self.roomManager.remoteParticipants.count - 1)].forEach { self.speakers.append(Speaker(remoteParticipant: $0)) }
                
                if self.roomManager.remoteParticipants.count > 5 {
                    self.roomManager.remoteParticipants[5...].forEach { self.offscreenSpeakers.append(Speaker(remoteParticipant: $0)) }
                }
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
                
                if self.speakers.count < 6 {
                    self.speakers.append(Speaker(remoteParticipant: remoteParticipant))
                } else {
                    self.offscreenSpeakers.append(Speaker(remoteParticipant: remoteParticipant))
                }
            }
            .store(in: &subscriptions)

        notificationCenter.publisher(for: .remoteParticipantDidDisconnect)
            .sink() { notification in
                guard let remoteParticipant = notification.object as? RoomRemoteParticipant else { return }

                if let index = self.speakers.index(of: remoteParticipant) {
                    self.speakers.remove(at: index)
                    
                    if !self.offscreenSpeakers.isEmpty {
                        self.speakers.append(self.offscreenSpeakers.removeFirst())
                    }
                } else {
                    self.offscreenSpeakers.removeAll { $0.identity == remoteParticipant.identity }
                }
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
                guard let remoteParticipant = notification.object as? RoomRemoteParticipant else { return }

                if let speakerIndex = self.speakers.index(of: remoteParticipant) {
                    self.speakers[speakerIndex].isDominantSpeaker = remoteParticipant.isDominantSpeaker
                } else if let speakerIndex = self.offscreenSpeakers.index(of: remoteParticipant) {
                    if remoteParticipant.isDominantSpeaker {
                        // Find oldest dominant speaker
                        let sortedSpeakers = self.speakers[1...].sorted { $0.dominantSpeakerTimestamp < $1.dominantSpeakerTimestamp }
                        print(sortedSpeakers)
                        
                        let oldest = sortedSpeakers.first! // Don't bang
                        // Move them offscreen
                        
                        let oldestIndex = self.speakers.firstIndex { $0.identity == oldest.identity }!
                        
                        self.speakers.remove(at: oldestIndex)
                        
                        // Move new dominant speaker onscreen
                        self.speakers.insert(self.offscreenSpeakers.remove(at: speakerIndex), at: oldestIndex)
                        self.speakers[oldestIndex].isDominantSpeaker = true
                        self.offscreenSpeakers.insert(oldest, at: 0)
                    } else {
                        self.offscreenSpeakers[speakerIndex].isDominantSpeaker = remoteParticipant.isDominantSpeaker
                    }
                }
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
