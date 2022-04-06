//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI

struct AdvancedSettings: View {
    @EnvironmentObject var appSettingsManager: AppSettingsManager

    var body: some View {
        Form {
            Section(footer: Text("Environment is used by Twilio employees for internal testing only.")) {
                Picker("Environment", selection: $appSettingsManager.environment) {
                    ForEach(TwilioEnvironment.allCases) {
                        Text($0.rawValue.capitalized)
                    }
                }
            }
        }
        .navigationTitle("Advanced")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AdvancedSettings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AdvancedSettings()
                .environmentObject(AppSettingsManager.stub())
        }
    }
}

extension AppSettingsManager {
    static func stub(environment: TwilioEnvironment = .prod) -> AppSettingsManager {
        let appSettingsManager = AppSettingsManager()
        appSettingsManager.environment = environment
        return appSettingsManager
    }
}
