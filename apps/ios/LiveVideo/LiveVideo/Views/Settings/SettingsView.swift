//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI
import SwiftyUserDefaults
import TwilioLivePlayer
import TwilioVideo

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage(DefaultsKeys().twilioEnvironment._key) var environment: TwilioEnvironment = DefaultsKeys().twilioEnvironment.defaultValue!
    @Binding var signOut: Bool

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TitleValueView(title: "App Version", value: AppInfoStore().version)
                    TitleValueView(title: "Player SDK Version", value: Player.sdkVersion())
                    TitleValueView(title: "Video SDK Version", value: TwilioVideoSDK.sdkVersion())
                }
                
                Section(
                    header: Text("Internal"),
                    footer: Text("Settings used by Twilio for internal testing.")
                ) {
                    Picker("Environment", selection: $environment) {
                        ForEach(TwilioEnvironment.allCases) {
                            Text($0.rawValue.capitalized)
                        }
                    }
                }
                
                Section {
                    Button("Sign Out") {
                        signOut = true
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("Settings")
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(signOut: .constant(false))
    }
}
