//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import TwilioSyncClient

class ViewerStore: NSObject, SyncStoring, ObservableObject {
    let speakerInvitePublisher = PassthroughSubject<Void, Never>()
    var isHandRaised = false {
        didSet {
            document?.mutateData(
                {
                    $0?["hand_raised"] = self.isHandRaised
                    return $0
                },
                metadata: nil,
                completion: nil // TODO: Handle error
            )
        }
    }
    var documentName: String!
    private var document: TWSDocument?
    
    func connect(client: TwilioSyncClient, completion: @escaping (Error?) -> Void) {
        guard let options = TWSOpenOptions.open(withSidOrUniqueName: documentName) else { return }
        
        client.openDocument(with: options, delegate: self) { [weak self] result, document in
            if let error = result.error {
                completion(error)
                return
            }
            
            self?.document = document
            completion(nil)
        }
    }
    
    func disconnect() {
        document = nil
        isHandRaised = false
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
}
