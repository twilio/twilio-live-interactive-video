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
                    self?.handleError(error)
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
    
    private func handleError(_ error: Error) {
        disconnect()
        errorPublisher.send(error)
    }
}

extension SyncManager: TwilioSyncClientDelegate {
    func syncClient(_ client: TwilioSyncClient, connectionStateChanged state: TWSClientConnectionState) {
        switch state {
        case .unknown, .disconnected, .connected, .connecting, .denied, .error:
            break
        case .fatalError:
            handleError(LiveVideoError.syncClientConnectionFatalError)
        @unknown default:
            break
        }
    }
    
    func syncClientTokenExpired(_ client: TwilioSyncClient) {
        /// Should never happen because streams are not long living.
        handleError(LiveVideoError.syncTokenExpired)
    }
}
