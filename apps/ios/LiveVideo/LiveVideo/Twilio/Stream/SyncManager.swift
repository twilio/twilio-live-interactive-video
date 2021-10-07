//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import TwilioSyncClient

class SyncManager: NSObject {
    let syncClientPublisher = PassthroughSubject<Void, Never>()
    private(set) var client: TwilioSyncClient?
    private(set) var roomSID: String!

    func configure(token: String, roomSID: String) {
        self.roomSID = roomSID

        let properties = TwilioSyncClientProperties()
        
        TwilioSyncClient.syncClient(
            withToken: token,
            properties: properties,
            delegate: self
        ) { [weak self] result, client in
            if let error = result.error {
                print("Failed to get sync client: \(error)")
                print("token: \(token)")
                return
            }

            print("Got sync client!")
            self?.client = client
            self?.syncClientPublisher.send()
        }
    }
}

extension SyncManager: TwilioSyncClientDelegate {
    
}
