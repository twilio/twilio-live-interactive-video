//
//  Copyright (C) 2021 Twilio, Inc.
//

import TwilioSyncClient

class RaisedHandsStore: NSObject, ObservableObject, SyncStoring {
    struct RaisedHand: Identifiable {
        let userIdentity: String
        var id: String { userIdentity }
        
        init(mapItem: TWSMapItem) {
            userIdentity = mapItem.key
        }
    }

    @Published var raisedHands: [RaisedHand] = []
    var mapName: String!
    private var map: TWSMap?

    func connect(client: TwilioSyncClient, completion: @escaping (Error?) -> Void) {
        guard let openOptions = TWSOpenOptions.open(withSidOrUniqueName: mapName) else { return }

        client.openMap(with: openOptions, delegate: self) { [weak self] result, map in
            if let error = result.error {
                completion(error)
                return
            }
            
            self?.map = map

            /// If there are more than 100 raised hands they just won't show up and that is fine because
            /// it is too many raised hands for a host to manage anyway.
            let queryOptions = TWSMapQueryOptions().withPageSize(100)

            map?.queryItems(with: queryOptions) { result, paginator in
                if let error = result.error {
                    completion(error)
                    return
                }

                self?.raisedHands = paginator?.getItems().map { RaisedHand(mapItem: $0) } ?? []
                completion(nil)
            }
        }
    }
    
    func disconnect() {
        map = nil
        raisedHands = []
    }
}

extension RaisedHandsStore: TWSMapDelegate {
    func onMap(_ map: TWSMap, itemAdded item: TWSMapItem, eventContext: TWSEventContext) {
        raisedHands.append(RaisedHand(mapItem: item))
    }
    
    func onMap(_ map: TWSMap, itemRemovedWithKey itemKey: String, previousItemData: [String : Any], eventContext: TWSEventContext) {
        raisedHands.removeAll { $0.userIdentity == itemKey }
    }
}
