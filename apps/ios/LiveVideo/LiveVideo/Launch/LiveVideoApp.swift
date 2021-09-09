//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

@main
struct LiveVideoApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var streamManager = StreamManager(
        api: API.shared,
        roomManager: RoomManager(),
        playerManager: PlayerManager()
    )
    @StateObject private var streamViewModel = StreamViewModel()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(authManager)
                .environmentObject(streamManager)
                .environmentObject(streamViewModel)
        }
    }
}
