//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

@main
struct LiveVideoApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var streamManager = StreamManager(api: API.shared, playerManager: PlayerManager())
    @StateObject private var speakerSettingsManager = SpeakerSettingsManager()
    @StateObject private var speakerGridViewModel = SpeakerGridViewModel()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(authManager)
                .environmentObject(streamManager)
                .environmentObject(speakerGridViewModel)
                .environmentObject(speakerSettingsManager)
                .onAppear {
                    let roomManager = RoomManager()
                    roomManager.localParticipant = LocalParticipantManager(identity: authManager.userIdentity)
                    streamManager.roomManager = roomManager
                    speakerSettingsManager.localParticipant = roomManager.localParticipant
                }
        }
    }
}
