//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI

class AppSettingsManager: ObservableObject {
    @AppStorage("TwilioEnvironment") var environment: TwilioEnvironment = .prod
}
