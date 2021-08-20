//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

class AppInfoStore {
    var version: String { bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String }
    private let bundle = Bundle.main
}
