//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI

struct SignInSettingsView: View {
    @Binding var environment: TwilioEnvironment
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            Form {
                Section(footer: Text("Environment is used by Twilio employees for internal testing only.")) {
                    Picker("Environment", selection: $environment) {
                        ForEach(TwilioEnvironment.allCases) {
                            Text($0.rawValue.capitalized)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct SignInSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SignInSettingsView(environment: .constant(.prod), isPresented: .constant(true))
    }
}
