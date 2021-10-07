//
//  Copyright (C) 2021 Twilio, Inc.
//

import TwilioSyncClient

class SyncRaisedHandsMapManager: NSObject, ObservableObject {
    @Published var raisedHands: [RaisedHand] = []
    private var client: TwilioSyncClient!
    private var roomSID: String!
    private var map: TWSMap?

    func configure(client: TwilioSyncClient, roomSID: String ) {
        self.client = client
        self.roomSID = roomSID
        fetchMyDoc()
    }

    func fetchMyDoc() {
        guard let options = TWSOpenOptions.open(withSidOrUniqueName: "raised_hands-\(roomSID ?? "")") else {
            print("Failed to open user doc.")
            return
        }

        client?.openMap(with: options, delegate: self) { [weak self] result, map in
            if let error = result.error {
                print("Failed to open raised hands map: \(error)")
                return
            }
            
            print("Fetch raised hands map successful.")
            self?.map = map
            
            let queryOptions = TWSMapQueryOptions()
            
            map?.queryItems(with: queryOptions) { [weak self] result, paginator in
                guard result.isSuccessful else { return }
                
                self?.raisedHands = paginator?.getItems().map { RaisedHand(name: $0.key) } ?? []
            }
        }
    }
}

extension SyncRaisedHandsMapManager: TWSMapDelegate {
    func onMap(_ map: TWSMap, itemAdded item: TWSMapItem, eventContext: TWSEventContext) {
        raisedHands.append(RaisedHand(name: item.key))
    }
    
    func onMap(_ map: TWSMap, itemRemovedWithKey itemKey: String, previousItemData: [String : Any], eventContext: TWSEventContext) {
        raisedHands.removeAll { $0.name == itemKey }
    }
}


struct RaisedHand: Identifiable {
    var id: String { name }
    
    let name: String
}
