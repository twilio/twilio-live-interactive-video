//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftyUserDefaults

enum TwilioEnvironment: String, CaseIterable, Identifiable, DefaultsSerializable {
    case prod
    case stage
    case dev

    var id: Self {
        self
    }
    
    var domain: String {
        switch self {
        case .prod: return "twil.io"
        case .stage: return "stage.twil.io"
        case .dev: return "dev.twil.io"
        }
    }
    
    var region: String {
        switch self {
        case .prod: return "us1"
        case .stage: return "stage-us1"
        case .dev: return "dev-us1"
        }
    }
}
