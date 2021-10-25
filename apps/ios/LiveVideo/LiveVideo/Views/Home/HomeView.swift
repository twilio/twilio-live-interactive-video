//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var streamManager: StreamManager
    @State private var showSettings = false
    @State private var showStream = false
    @State private var signOut = false
    @StateObject private var streamConfigFlowModel = StreamConfigFlowModel()
    
    var body: some View {
        NavigationView {
            FormStack {
                Text("Create your own event or join one that’s already happening.")
                    .foregroundColor(.textWeak)
                    .font(.system(size: 15))
                Button(
                    action: {
                        streamConfigFlowModel.parameters = StreamConfigFlowModel.Parameters()
                        streamConfigFlowModel.parameters.role = .host
                        streamConfigFlowModel.isShowing = true
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
                        streamConfigFlowModel.parameters = StreamConfigFlowModel.Parameters()
                        streamConfigFlowModel.isShowing = true
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
                isPresented: $streamConfigFlowModel.isShowing,
                onDismiss: {
                    guard
                        let streamName = streamConfigFlowModel.parameters.streamName,
                        let role = streamConfigFlowModel.parameters.role
                    else {
                        return
                    }
                    
                    streamManager.config = StreamConfig(
                        streamName: streamName,
                        userIdentity: authManager.userIdentity,
                        role: role
                    )
                    showStream = true
                },
                content: {
                    EnterStreamNameView()
                        .environmentObject(streamConfigFlowModel)
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
