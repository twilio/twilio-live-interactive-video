//
//  Copyright (C) 2022 Twilio, Inc.
//

import Foundation

enum TwilioEnvironment: String, CaseIterable, Identifiable {
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
    
    var environmentVariableValue: String {
        switch self {
        case .prod: return "Production"
        case .stage: return "Staging"
        case .dev: return "Development"
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
