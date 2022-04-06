//
//  Copyright (C) 2021 Twilio, Inc.
//

import SwiftyUserDefaults

extension DefaultsKeys {
    var twilioEnvironment: DefaultsKey<TwilioEnvironment> { .init("TwilioEnvironment", defaultValue: .prod) }
}
