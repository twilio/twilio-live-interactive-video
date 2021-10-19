//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftyUserDefaults
import TwilioLivePlayer
import TwilioVideo

class UserDefaultsManager {
    func sync() {
        Defaults.appVersion = AppInfoStore().version
        Defaults.playerSDKVersion = Player.sdkVersion()
        Defaults.videoSDKVersion = TwilioVideoSDK.sdkVersion()
    }
}
