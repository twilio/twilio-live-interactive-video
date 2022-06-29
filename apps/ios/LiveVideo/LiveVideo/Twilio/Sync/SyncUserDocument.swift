//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import TwilioSyncClient

class SyncUserDocument: NSObject, SyncObjectConnecting {
    let speakerInvitePublisher = PassthroughSubject<Void, Never>()
    var uniqueName: String!
    var errorHandler: ((Error) -> Void)?
    private var document: TWSDocument?
    
    func connect(client: TwilioSyncClient, completion: @escaping (Error?) -> Void) {
        guard let options = TWSOpenOptions.open(withSidOrUniqueName: uniqueName) else { return }
        
        client.openDocument(with: options, delegate: self) { [weak self] result, document in
            guard let document = document else {
                completion(result.error!)
                return
            }
            
            self?.document = document
            completion(nil)
        }
    }
    
    func disconnect() {
        document = nil
    }
}

extension SyncUserDocument: TWSDocumentDelegate {
    func onDocument(
        _ document: TWSDocument,
        updated data: [String : Any],
        previousData: [String : Any],
        eventContext: TWSEventContext
    ) {
        if let speakerInvite = data["speaker_invite"] as? Bool, speakerInvite {
            speakerInvitePublisher.send()
        }
    }
    
    func onDocument(_ document: TWSDocument, errorOccurred error: TWSError) {
        disconnect()
        errorHandler?(error)
    }
}
