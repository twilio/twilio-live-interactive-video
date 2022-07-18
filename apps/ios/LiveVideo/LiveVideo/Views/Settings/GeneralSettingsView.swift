//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI
import TwilioLivePlayer
import TwilioVideo

struct GeneralSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var signOut: Bool

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TitleValueView(title: "App Version", value: AppInfoStore().version)
                    TitleValueView(title: "Player SDK Version", value: Player.sdkVersion())
                    TitleValueView(title: "Video SDK Version", value: TwilioVideoSDK.sdkVersion())
                }
                
                Section {
                    Button("Sign Out") {
                        signOut = true
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                signOut = false
            }
        }
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView(signOut: .constant(false))
    }
}
