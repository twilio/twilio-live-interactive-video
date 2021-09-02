//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

@main
struct LiveVideoApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var streamManager = StreamManager()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(authManager)
                .environmentObject(streamManager)
        }
    }
}
