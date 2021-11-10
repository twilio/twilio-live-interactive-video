//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import TwilioSyncClient

/// Consolidates configuration and error handling for stores that are backed by [Twilio Sync](https://www.twilio.com/sync).
class SyncManager: NSObject {
    let errorPublisher = PassthroughSubject<Error, Never>()
    var isConnected: Bool { client != nil }
    private var client: TwilioSyncClient?
    private var raisedHandsStore: SyncUsersStore
    private var viewersStore: SyncUsersStore
    private var viewerStore: ViewerStore
    private var stores: [SyncStoring] = []

    init(viewersStore: SyncUsersStore, raisedHandsStore: SyncUsersStore, viewerStore: ViewerStore) {
        self.viewersStore = viewersStore
        self.raisedHandsStore = raisedHandsStore
        self.viewerStore = viewerStore
    }

    /// Connects all sync stores that have a configuration.
    ///
    /// - Parameter token: An access token with sync grant.
    /// - Parameter raisedHandsMapName: The unique name for the raised hands map.
    /// - Parameter viewerDocumentName: The unique name for the viewer document.
    /// - Parameter completion: Called when all configured stores are synchronnized or an error is encountered.
    func connect(
        token: String,
        viewersMapName: String,
        raisedHandsMapName: String,
        viewerDocumentName: String?,
        completion: @escaping (Error?) -> Void
    ) {
        viewersStore.uniqueName = viewersMapName
        raisedHandsStore.uniqueName = raisedHandsMapName
        stores = [viewersStore, raisedHandsStore]
        
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
