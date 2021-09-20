//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showSettings = false
    @State private var showCreateStream = false
    @State private var showJoinStream = false
    @State private var showStream = false
    @State private var signOut = false
    @State private var streamConfig: StreamConfig?

    var body: some View {
        NavigationView {
            FormStack {
                Text("Create or join?")
                    .font(.system(size: 28, weight: .bold))
                Text("Create your own event or join one that’s already happening.")
                    .foregroundColor(.textIcon)
                    .font(.system(size: 15))
                Button("Create Event") {
                    showCreateStream = true
                }
                Button("Join Event") {
                    showJoinStream = true
                }
            }
            .buttonStyle(PrimaryButtonStyle()) // TODO: Add to FormStack
            .toolbar {
                Button(action: { showSettings.toggle() }) {
                    Image(systemName: "gear")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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
                isPresented: $showCreateStream,
                onDismiss: {
                    showStream = streamConfig != nil
                },
                content: {
                    JoinStreamView(streamConfig: $streamConfig, mode: .create) // TODO: CreateStreamView
                }
            )
            .sheet(
                isPresented: $showJoinStream,
                onDismiss: {
                    showStream = streamConfig != nil
                },
                content: {
                    JoinStreamView(streamConfig: $streamConfig, mode: .join)
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
