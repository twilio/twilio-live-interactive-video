//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftUI

struct JoinStreamView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.presentationMode) var presentationMode
    @Binding var streamConfig: StreamConfig?
    @State private var roomName = ""
    
    var body: some View {
        NavigationView {
            FormStack {
                TextField("Event name", text: $roomName)
                    .textFieldStyle(FormTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                Button("Continue") {
                    streamConfig = StreamConfig(roomName: roomName, userIdentity: authManager.userIdentity)
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(PrimaryButtonStyle(isEnabled: !roomName.isEmpty))
                .disabled(roomName.isEmpty)
            }
            .navigationBarTitle("Join event", displayMode: .inline)
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
        JoinStreamView(streamConfig: .constant(nil))
    }
}
