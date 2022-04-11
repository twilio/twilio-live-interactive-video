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
        let userDocument: String?
    }

    let errorPublisher = PassthroughSubject<Error, Never>()
    var isConnected: Bool { client != nil }
    private var client: TwilioSyncClient?
    private var speakersMap: SyncUsersMap
    private var raisedHandsMap: SyncUsersMap
    private var viewersMap: SyncUsersMap
    private var userDocument: SyncUserDocument
    private var objects: [SyncObjectConnecting] = []
    private var appSettingsManager: AppSettingsManager

    init(
        speakersMap: SyncUsersMap,
        viewersMap: SyncUsersMap,
        raisedHandsMap: SyncUsersMap,
        userDocument: SyncUserDocument,
        appSettingsManager: AppSettingsManager
    ) {
        self.speakersMap = speakersMap
        self.viewersMap = viewersMap
        self.raisedHandsMap = raisedHandsMap
        self.userDocument = userDocument
        self.appSettingsManager = appSettingsManager
    }

    /// Connects all sync objects.
    ///
    /// - Parameter token: An access token with sync grant.
    /// - Parameter objectNames: Unique names for the sync objects.
    /// - Parameter completion: Called when all configured objects are synchronnized or an error is encountered.
    func connect(token: String, objectNames: ObjectNames, completion: @escaping (Error?) -> Void
    ) {
        speakersMap.uniqueName = objectNames.speakersMap
        viewersMap.uniqueName = objectNames.viewersMap
        raisedHandsMap.uniqueName = objectNames.raisedHandsMap
        objects = [speakersMap, viewersMap, raisedHandsMap]
        
        if let userDocumentName = objectNames.userDocument {
            userDocument.uniqueName = userDocumentName
            objects.append(userDocument)
        }
        
        let properties = TwilioSyncClientProperties()
        
        if let region = appSettingsManager.environment.region {
            properties.region = region /// Only used by Twilio employees for internal testing
        }
        
        TwilioSyncClient.syncClient(
            withToken: token,
            properties: properties,
            delegate: self
        ) { [weak self] result, client in
            guard let client = client else {
                completion(result.error!)
                return
            }

            self?.client = client

            var connectedObjectCount = 0
            
            self?.objects.forEach { object in
                object.errorHandler = { error in
                    self?.handleError(error)
                }
                
                object.connect(client: client) { error in
                    if let error = error {
                        self?.disconnect()
                        completion(error)
                        return
                    }
                    
                    connectedObjectCount += 1
                    
                    if connectedObjectCount == self?.objects.count {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func disconnect() {
        client?.shutdown()
        client = nil
        objects.forEach { $0.disconnect() }
        objects = []
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
