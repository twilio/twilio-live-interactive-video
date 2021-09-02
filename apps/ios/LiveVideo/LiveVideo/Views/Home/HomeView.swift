//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showSettings = false
    @State private var showJoinStream = false
    @State private var showStream = false
    @State private var signOut = false
    @State private var streamConfig: StreamConfig?

    var body: some View {
        NavigationView {
            FormStack {
                Spacer()
                Button("Join Event") {
                    showJoinStream = true
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .toolbar {
                Button(action: { showSettings.toggle() }) {
                    Image(systemName: "gear")
                }
            }
            .sheet(
                isPresented: $showSettings,
                onDismiss: {
                    if signOut {
                        authManager.signOut()
                    }
                },
                content: {
                    SettingsView(signOut: $signOut)
                }
            )
            .sheet(
                isPresented: $showJoinStream,
                onDismiss: {
                    showStream = streamConfig != nil
                },
                content: {
                    JoinStreamView(streamConfig: $streamConfig)
                }
            )
            .fullScreenCover(isPresented: $authManager.isSignedOut, content: {
                SignInView()
            })
            .fullScreenCover(isPresented: $showStream, content: {
                StreamView(config: $streamConfig)
            })
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let authManager = AuthManager()
        authManager.signIn(userIdentity: "Alice")
        
        return HomeView()
            .environmentObject(authManager)
    }
}
