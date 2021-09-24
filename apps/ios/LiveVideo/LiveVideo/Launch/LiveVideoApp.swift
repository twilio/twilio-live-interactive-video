//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

@main
struct LiveVideoApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var streamManager = StreamManager(
        api: API.shared,
        playerManager: PlayerManager()
    )
    @StateObject private var roomManager = RoomManager()
    @StateObject private var speakerStore = SpeakerStore()
    @StateObject private var localParticipantViewModel = LocalParticipantViewModel()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(authManager)
                .environmentObject(streamManager)
                .environmentObject(speakerStore)
                .environmentObject(roomManager)
                .environmentObject(localParticipantViewModel)
                .onAppear {
                    streamManager.roomManager = roomManager
                    speakerStore.roomManager = roomManager
                    roomManager.localParticipant = LocalParticipantManager(identity: authManager.userIdentity)
                    localParticipantViewModel.localParticipant = roomManager.localParticipant
                }
        }
    }
}
