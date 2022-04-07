//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI

struct SignInSettingsView: View {
    @EnvironmentObject var appSettingsManager: AppSettingsManager
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            Form {
                Section(footer: Text("Environment is used by Twilio employees for internal testing only.")) {
                    Picker("Environment", selection: $appSettingsManager.environment) {
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
        SignInSettingsView(isPresented: .constant(true))
            .environmentObject(AppSettingsManager.stub())
    }
}

extension AppSettingsManager {
    static func stub(environment: TwilioEnvironment = .prod) -> AppSettingsManager {
        let appSettingsManager = AppSettingsManager()
        appSettingsManager.environment = environment
        return appSettingsManager
    }
}
