//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var streamManager: StreamManager
    @State private var showSettings = false
    @State private var showCreateStream = false
    @State private var showJoinStream = false
    @State private var showStream = false
    @State private var signOut = false
    @State private var streamConfig: StreamConfig?

    var body: some View {
        NavigationView {
            FormStack {
                Text("Create your own event or join one that’s already happening.")
                    .foregroundColor(.textWeak)
                    .font(.system(size: 15))
                Button(
                    action: {
                        showCreateStream = true
                    },
                    label: {
                        CardButtonLabel(
                            title: "Create event",
                            image: Image(systemName: "plus.square"),
                            imageColor: .backgroundSuccess
                        )
                    }
                )
                Button(
                    action: {
                        showJoinStream = true
                    },
                    label: {
                        CardButtonLabel(
                            title: "Join event",
                            image: Image(systemName: "person.3"),
                            imageColor: .cardButtonIconPurple
                        )
                    }
                )
            }
            .navigationTitle("Create or join?")
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
                isPresented: $showCreateStream,
                onDismiss: {
                    showStream = streamConfig != nil
                    streamManager.config = streamConfig
                },
                content: {
                    JoinStreamView(streamConfig: $streamConfig, mode: .create)
                }
            )
            .sheet(
                isPresented: $showJoinStream,
                onDismiss: {
                    showStream = streamConfig != nil
                    streamManager.config = streamConfig
                },
                content: {
                    JoinStreamView(streamConfig: $streamConfig, mode: .join)
                }
            )
            .fullScreenCover(isPresented: $authManager.isSignedOut) {
                SignInView()
            }
            .fullScreenCover(isPresented: $showStream) {
                StreamView()
            }
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
