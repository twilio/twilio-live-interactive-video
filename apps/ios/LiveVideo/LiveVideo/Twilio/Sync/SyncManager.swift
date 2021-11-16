//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import TwilioSyncClient

/// Consolidates configuration and error handling for stores that are backed by [Twilio Sync](https://www.twilio.com/sync).
class SyncManager: NSObject {
    struct ObjectNames {
        let speakersMap: String
        let viewersMap: String
        let raisedHandsMap: String
        let viewerDocument: String?
    }

    let errorPublisher = PassthroughSubject<Error, Never>()
    var isConnected: Bool { client != nil }
    private var client: TwilioSyncClient?
    private var speakersStore: SyncUsersStore
    private var raisedHandsStore: SyncUsersStore
    private var viewersStore: SyncUsersStore
    private var viewerStore: ViewerStore
    private var stores: [SyncStoring] = []

    init(
        speakersStore: SyncUsersStore,
        viewersStore: SyncUsersStore,
        raisedHandsStore: SyncUsersStore,
        viewerStore: ViewerStore
    ) {
        self.speakersStore = speakersStore
        self.viewersStore = viewersStore
        self.raisedHandsStore = raisedHandsStore
        self.viewerStore = viewerStore
    }

    /// Connects all sync stores.
    ///
    /// - Parameter token: An access token with sync grant.
    /// - Parameter objectNames: Unique names for the sync objects.
    /// - Parameter completion: Called when all configured stores are synchronnized or an error is encountered.
    func connect(token: String, objectNames: ObjectNames, completion: @escaping (Error?) -> Void
    ) {
        speakersStore.uniqueName = objectNames.speakersMap
        viewersStore.uniqueName = objectNames.viewersMap
        raisedHandsStore.uniqueName = objectNames.raisedHandsMap
        stores = [speakersStore, viewersStore, raisedHandsStore]
        
        if let viewerDocumentName = objectNames.viewerDocument {
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
