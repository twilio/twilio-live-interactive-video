//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

class StreamConfigFlowModel: ObservableObject {
    struct Parameters {
        var streamName: String?
        var role: StreamConfig.Role?
    }

    @Published var isShowing = false
    var parameters = Parameters()
}
