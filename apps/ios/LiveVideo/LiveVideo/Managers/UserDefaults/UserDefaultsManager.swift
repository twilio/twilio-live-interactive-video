//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftyUserDefaults
import TwilioVideo

class UserDefaultsManager {
    func sync() {
        Defaults.appVersion = AppInfoStore().version
        Defaults.videoSDKVersion = TwilioVideoSDK.sdkVersion()
    }
}
