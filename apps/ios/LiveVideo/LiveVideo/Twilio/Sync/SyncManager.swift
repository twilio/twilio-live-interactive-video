//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import TwilioSyncClient

class SyncManager: NSObject {
    var isConnected: Bool { client?.connectionState == .connected }
    private var client: TwilioSyncClient?

    func connect(token: String, stores: [SyncStoring], completion: @escaping (Error?) -> Void) {
        let properties = TwilioSyncClientProperties()
        
        TwilioSyncClient.syncClient(
            withToken: token,
            properties: properties,
            delegate: self
        ) { [weak self] result, client in
            if let error = result.error {
                completion(error)
                return
            }

            self?.client = client

            var connectedStoreCount = 0
            
            stores.forEach { store in
                store.connect(client: client!) { error in
                    if client?.connectionState != .connected {
                        return // An error was already reported so silently stop
                    }

                    if let error = result.error {
                        client?.shutdown() // TODO: Make sure
                        completion(error)
                        return
                    }
                    
                    connectedStoreCount += 1
                    
                    if connectedStoreCount == stores.count {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func disconnect() {
        client?.shutdown()
    }
}

extension SyncManager: TwilioSyncClientDelegate {
    
}




protocol SyncStoring {
    func connect(client: TwilioSyncClient, completion: @escaping (Error?) -> Void)
}
