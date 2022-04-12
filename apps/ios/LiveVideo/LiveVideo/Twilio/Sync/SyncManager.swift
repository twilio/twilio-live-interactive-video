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
    private var speakersMap: SyncUsersMap
    private var raisedHandsMap: SyncUsersMap
    private var viewersMap: SyncUsersMap
    private var userDocument: SyncUserDocument
    private var streamDocument: SyncStreamDocument
    private var objects: [SyncObjectConnecting] = []
    private var appSettingsManager: AppSettingsManager

    init(
        speakersMap: SyncUsersMap,
        viewersMap: SyncUsersMap,
        raisedHandsMap: SyncUsersMap,
        userDocument: SyncUserDocument,
        streamDocument: SyncStreamDocument,
        appSettingsManager: AppSettingsManager
    ) {
        self.speakersMap = speakersMap
        self.viewersMap = viewersMap
        self.raisedHandsMap = raisedHandsMap
        self.userDocument = userDocument
        self.streamDocument = streamDocument
        self.appSettingsManager = appSettingsManager
    }

    /// Connects all sync objects.
    ///
    /// - Parameter token: An access token with sync grant.
    /// - Parameter userIdentity: Identity of the user.
    /// - Parameter hasUserDocument: If there is a user document to open.
    /// - Parameter completion: Called when all configured objects are synchronnized or an error is encountered.
    func connect(
        token: String,
        userIdentity: String,
        hasUserDocument: Bool,
        completion: @escaping (Error?) -> Void
    ) {
        objects = [speakersMap, viewersMap, raisedHandsMap, streamDocument]

        if hasUserDocument {
            userDocument.uniqueName = "user-" + userIdentity
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
