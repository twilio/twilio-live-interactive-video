//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import TwilioSyncClient

class SyncClientManager: NSObject {
    let syncClientPublisher = PassthroughSubject<Void, Never>()
    @Published private(set) var client: TwilioSyncClient?
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

extension SyncClientManager: TwilioSyncClientDelegate {
    
}
