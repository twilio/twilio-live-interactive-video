//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct JoinStreamView: View {
    struct Mode: Equatable {
        let title: String
        
        static let create = Mode(title: "Create event")
        static let join = Mode(title: "Join event")
    }
    
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.presentationMode) var presentationMode
    @Binding var streamConfig: StreamConfig?
    let mode: Mode
    @State private var streamName = ""
    @State private var favoriteColor = 0
    
    var body: some View {
        NavigationView {
            FormStack {
                TextField("Event name", text: $streamName)
                    .textFieldStyle(FormTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                Picker("What is your favorite color?", selection: $favoriteColor) {
                    Text("Viewer").tag(0)
                    Text("Speaker").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 10)
                
                Button("Continue") {
                    streamConfig = StreamConfig(
                        streamName: streamName,
                        userIdentity: authManager.userIdentity,
                        role: mode == .create ? .host : .viewer
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
