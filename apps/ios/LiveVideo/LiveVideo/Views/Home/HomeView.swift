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
                Text("Create or join?")
                    .font(.system(size: 28, weight: .bold))
                Text("Create your own event or join one that’s already happening.")
                    .modifier(TipStyle())
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
                            imageColor: .iconPurple
                        )
                    }
                )
            }
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
                isPresented: $streamConfigFlowModel.isShowing,
                onDismiss: {
                    guard let config = streamConfigFlowModel.config else {
                        return // The user concelled
                    }
                    
                    streamManager.config = config
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
