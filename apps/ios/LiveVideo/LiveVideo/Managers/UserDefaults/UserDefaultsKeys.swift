//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftyUserDefaults

extension DefaultsKeys {
    var appVersion: DefaultsKey<String> { .init("AppVersion", defaultValue: "") }
    var playerSDKVersion: DefaultsKey<String> { .init("PlayerSDKVersion", defaultValue: "") }
    var videoSDKVersion: DefaultsKey<String> { .init("VideoSDKVersion", defaultValue: "") }
}
