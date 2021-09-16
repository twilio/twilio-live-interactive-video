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
    @StateObject private var speakerStore = SpeakerStore()
    @StateObject private var roomManager = RoomManager()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(authManager)
                .environmentObject(streamManager)
                .environmentObject(speakerStore)
                .environmentObject(roomManager)
                .onAppear {
                    streamManager.roomManager = roomManager
                    streamManager.roomManager.speakerStore = speakerStore
                }
        }
    }
}
