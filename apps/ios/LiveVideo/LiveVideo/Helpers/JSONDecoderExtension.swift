//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

extension JSONDecoder {
    convenience init(keyDecodingStrategy: KeyDecodingStrategy) {
        self.init()
        self.keyDecodingStrategy = keyDecodingStrategy
    }
}
