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
                    .modifier(TitleStyle())
                Text("Create your own event or join one that’s already happening.")
                    .modifier(TipStyle())
                Button(
                    action: {
                        streamConfigFlowModel.parameters = StreamConfigFlowModel.Parameters()
                        streamConfigFlowModel.parameters.role = .host
                        streamConfigFlowModel.isShowing = true
                    },
                    label: {
                        CardButtonLabel(title: "Create event", image: Image(systemName: "plus.square"))
                    }
                )
                Button(
                    action: {
                        streamConfigFlowModel.parameters = StreamConfigFlowModel.Parameters()
                        streamConfigFlowModel.isShowing = true
                    },
                    label: {
                        CardButtonLabel(title: "Join event", image: Image(systemName: "person.3"))
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
                    GeneralSettingsView(signOut: $signOut)
                }
            )
            .sheet(
                isPresented: $streamConfigFlowModel.isShowing,
                onDismiss: {
                    guard let config = streamConfigFlowModel.config else {
                        return // The user concelled
                    }
                    
                    streamManager.config = config

                    // Had to make this async because sometimes there was an error reporting multiple sheets
                    // presented at the same time. This seems like a SwiftUI bug.
                    DispatchQueue.main.async {
                        showStream = true
                    }
                },
                content: {
                    EnterStreamNameView()
                        .environmentObject(streamConfigFlowModel)
                }
            )
            .fullScreenCover(isPresented: $authManager.isSignedOut) {
                EnterUserIdentityView()
            }
            .fullScreenCover(isPresented: $showStream) {
                StreamView()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        return HomeView()
            .environmentObject(AuthManager.stub(isSignedOut: false))
    }
}

private extension AuthManager {
    static func stub(userIdentity: String = "", isSignedOut: Bool = true) -> AuthManager {
        let authManager = AuthManager()
        authManager.userIdentity = userIdentity
        authManager.isSignedOut = isSignedOut
        return authManager
    }
}
