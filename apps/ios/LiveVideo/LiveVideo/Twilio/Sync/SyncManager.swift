//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import TwilioSyncClient

class SyncManager: NSObject {
    let errorPublisher = PassthroughSubject<Error, Never>()
    private var client: TwilioSyncClient?
    private var raisedHandsStore: RaisedHandsStore
    private var viewerStore: ViewerStore
    private var stores: [SyncStoring] = []

    init(raisedHandsStore: RaisedHandsStore, viewerStore: ViewerStore) {
        self.raisedHandsStore = raisedHandsStore
        self.viewerStore = viewerStore
    }
    
    func connect(
        token: String,
        raisedHandsMapName: String,
        viewerDocumentName: String?,
        completion: @escaping (Error?) -> Void
    ) {
        raisedHandsStore.uniqueName = raisedHandsMapName
        stores.append(raisedHandsStore)
        
        if let viewerDocumentName = viewerDocumentName {
            viewerStore.uniqueName = viewerDocumentName
            stores.append(viewerStore)
        }
        
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

            var connectedStoreCount = 0
            
            self?.stores.forEach { store in
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
                    
                    if connectedStoreCount == self?.stores.count {
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
    // TODO: Ask sync team if I need to handle error
}
