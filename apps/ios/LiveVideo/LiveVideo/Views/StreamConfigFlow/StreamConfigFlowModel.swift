//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

class StreamConfigFlowModel: ObservableObject {
    struct Parameters {
        var userIdentity: String?
        var streamName: String?
        var role: StreamConfig.Role?
    }

    @Published var isShowing = false
    var parameters = Parameters()
    
    var config: StreamConfig? {
        guard
            let userIdentity = parameters.userIdentity,
            let streamName = parameters.streamName,
            let role = parameters.role
        else {
            return nil
        }
        
        return StreamConfig(streamName: streamName, userIdentity: userIdentity, role: role)
    }
}
