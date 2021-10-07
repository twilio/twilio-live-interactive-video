//
//  Copyright (C) 2021 Twilio, Inc.
//

import TwilioSyncClient
import Combine

class SyncViewerDocumentManager: NSObject {
    var isHandRaised = false {
        didSet {
            guard let myDoc = myDoc else { return }
            
            myDoc.mutateData(
                {
                $0?["hand_raised"] = self.isHandRaised
                return $0
            }, metadata: nil, completion: nil)
        }
    }
    var authManager: AuthManager!
    private var client: TwilioSyncClient!
    private var roomSID: String!
    private var myDoc: TWSDocument?
    var videoRoomToken: String?
    let tokenPublisher = PassthroughSubject<String, Never>()
    
    func configure(client: TwilioSyncClient, roomSID: String ) {
        self.client = client
        self.roomSID = roomSID
        fetchMyDoc()
    }

    func fetchMyDoc() {
        guard let options = TWSOpenOptions.open(withSidOrUniqueName: "viewer-\(roomSID ?? "")-\(authManager.userIdentity)") else {
            print("Failed to open user doc.")
            return
        }
        
        client?.openDocument(with: options, delegate: self) { [weak self] result, document in
            if let error = result.error {
                print("Failed to open doc: \(error)")
                return
            }
            
            print("Fetch my doc successful.")
            self?.myDoc = document
        }
    }

}

extension SyncViewerDocumentManager: TWSDocumentDelegate {
    func onDocument(
        _ document: TWSDocument,
        updated data: [String : Any],
        previousData: [String : Any],
        eventContext: TWSEventContext
    ) {
        if let invite = data["speaker_invite"] as? [String: Any], let token = invite["video_room_token"] as? String {
            videoRoomToken = token
            tokenPublisher.send(token)
        }
    }
}


