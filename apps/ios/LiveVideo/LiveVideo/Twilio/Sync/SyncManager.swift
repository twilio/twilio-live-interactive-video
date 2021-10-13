//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import TwilioSyncClient

/// Coordinate connection and errors with client and sync objects.
class SyncManager: NSObject {
    let errorPublisher = PassthroughSubject<Error, Never>()
    var isConnected: Bool { client?.connectionState == .connected }
    private var client: TwilioSyncClient?
    private var stores: [SyncStoring] = []

    func connect(token: String, stores: [SyncStoring], completion: @escaping (Error?) -> Void) {
        TwilioSyncClient.syncClient(
            withToken: token,
            properties: nil,
            delegate: self
        ) { [weak self] result, client in
            guard let client = client else {
                completion(result.error!)
                return
            }

            self?.client = client
            self?.stores = stores

            var connectedStoreCount = 0
            
            stores.forEach { store in
                store.errorHandler = { error in
                    self?.disconnect()
                    self?.errorPublisher.send(error)
                }
                
                store.connect(client: client) { error in
                    if let error = error {
                        self?.disconnect()
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
        client = nil
        stores.forEach { $0.disconnect() }
        stores = []
    }
}

extension SyncManager: TwilioSyncClientDelegate {
    // TODO: Ask Sync team if I need to handle error
}
