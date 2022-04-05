//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI
import SwiftyUserDefaults

struct AdvancedSettings: View {
    @AppStorage(DefaultsKeys().twilioEnvironment._key) var environment: TwilioEnvironment = DefaultsKeys().twilioEnvironment.defaultValue!

    var body: some View {
        Form {
            Section(footer: Text("Environment is used by Twilio employees for internal testing only.")) {
                Picker("Environment", selection: $environment) {
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
        }
    }
}
