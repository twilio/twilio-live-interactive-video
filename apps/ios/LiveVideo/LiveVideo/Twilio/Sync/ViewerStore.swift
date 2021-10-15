//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import TwilioSyncClient

// TODO: Maybe change unique name
class ViewerStore: NSObject, SyncStoring, ObservableObject {
    let speakerInvitePublisher = PassthroughSubject<Void, Never>()
    var documentName: String! // TODO: Maybe rename
    var errorHandler: ((Error) -> Void)?
    private var document: TWSDocument?
    
    func connect(client: TwilioSyncClient, completion: @escaping (Error?) -> Void) {
        guard let options = TWSOpenOptions.open(withSidOrUniqueName: documentName) else { return }
        
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
    
    private func handleError(_ error: Error) {
        disconnect()
        errorHandler?(error)
    }
}

extension ViewerStore: TWSDocumentDelegate {
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
        handleError(error)
    }
}
