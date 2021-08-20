//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftyUserDefaults

extension DefaultsKeys {
    var appVersion: DefaultsKey<String> { .init("AppVersion", defaultValue: "") }
    var userIdentity: DefaultsKey<String> { .init("UserIdentity", defaultValue: "") }
    var videoSDKVersion: DefaultsKey<String> { .init("VideoSDKVersion", defaultValue: "") }
}
