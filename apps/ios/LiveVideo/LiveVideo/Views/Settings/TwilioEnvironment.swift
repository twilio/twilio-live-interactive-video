//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftyUserDefaults

enum TwilioEnvironment: String, CaseIterable, Identifiable, DefaultsSerializable {
    case production
    case staging
    case development

    var id: Self {
        self
    }
    
    var domain: String {
        switch self {
        case .production: return "twil.io"
        case .staging: return "stage.twil.io"
        case .development: return "dev.twil.io"
        }
    }
    
    var region: String? {
        switch self {
        case .production: return nil
        case .staging: return "stage-us1"
        case .development: return "dev-us1"
        }
    }
}
