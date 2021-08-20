//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var shouldShowSettings = false
    
    var body: some View {
        NavigationView {
            Text("\(authManager.userIdentity) is signed in. 😀")
                .padding()
            .toolbar {
                Button(action: { shouldShowSettings.toggle() }) {
                    Image(systemName: "gear")
                }
            }
            .fullScreenCover(isPresented: $authManager.isSignedOut, content: {
                SignInView()
            })
            .sheet(isPresented: $shouldShowSettings, content: {
                SettingsView(shouldShowSettings: $shouldShowSettings)
            })
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
