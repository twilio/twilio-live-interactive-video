//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

@main
struct LiveVideoApp: App {
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    @StateObject private var authManager = AuthManager()
    @StateObject private var streamManager = StreamManager()
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
                    let localParticipant = LocalParticipantManager(identity: authManager.userIdentity)
                    let roomManager = RoomManager()
                    roomManager.configure(localParticipant: localParticipant)
                    streamManager.configure(roomManager: roomManager, playerManager: PlayerManager(), api: API.shared)
                    speakerSettingsManager.configure(localParticipant: localParticipant)
                    speakerGridViewModel.configure(roomManager: roomManager)
                }
        }
    }
}
