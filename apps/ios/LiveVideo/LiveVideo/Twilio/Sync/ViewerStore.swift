//
//  Copyright (C) 2021 Twilio, Inc.
//

import Combine
import TwilioSyncClient

// TODO: Maybe change unique name
class ViewerStore: NSObject, SyncStoring, ObservableObject {
    let speakerInvitePublisher = PassthroughSubject<Void, Never>()
    var isHandRaised = false {
        didSet {
            document?.mutateData(
                {
                    $0?["hand_raised"] = self.isHandRaised // TODO: Test to make sure I don't need weak self
                    return $0
                },
                metadata: nil,
                completion: { [weak self] result, _ in
                    if let error = result.error {
                        self?.handleError(error)
                    }
                }
            )
        }
    }
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
        isHandRaised = false
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
