//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct JoinStreamView: View {
    struct Mode: Equatable {
        let title: String
        let shouldSelectViewerOrSpeaker: Bool
        
        static let create = Mode(title: "Create new event", shouldSelectViewerOrSpeaker: false)
        static let join = Mode(title: "Join event", shouldSelectViewerOrSpeaker: true)
    }
    
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.presentationMode) var presentationMode
    @Binding var streamConfig: StreamConfig?
    let mode: Mode
    @State private var streamName = ""
    @State private var role = StreamConfig.Role.viewer
    
    var body: some View {
        NavigationView {
            FormStack {
                TextField("Event name", text: $streamName)
                    .textFieldStyle(FormTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                if mode.shouldSelectViewerOrSpeaker {
                    Picker("What is your favorite color?", selection: $role) {
                        Text("Viewer").tag(StreamConfig.Role.viewer)
                        Text("Speaker").tag(StreamConfig.Role.speaker)
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 10)
                }
                
                Button("Continue") {
                    streamConfig = StreamConfig(
                        streamName: streamName,
                        userIdentity: authManager.userIdentity,
                        role: mode == .create ? .host : role
                    )
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(PrimaryButtonStyle(isEnabled: !streamName.isEmpty))
                .disabled(streamName.isEmpty)
            }
            .navigationBarTitle(mode.title, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            streamConfig = nil
        }
    }
}

struct JoinStreamView_Previews: PreviewProvider {
    static var previews: some View {
        JoinStreamView(streamConfig: .constant(nil), mode: .create)
        JoinStreamView(streamConfig: .constant(nil), mode: .join)
    }
}
