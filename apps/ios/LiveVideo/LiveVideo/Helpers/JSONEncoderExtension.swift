//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

extension JSONEncoder {
    convenience init(keyEncodingStrategy: KeyEncodingStrategy) {
        self.init()
        self.keyEncodingStrategy = keyEncodingStrategy
    }
}
