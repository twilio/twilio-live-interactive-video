//
//  Copyright (C) 2021 Twilio, Inc.
//

import TwilioSyncClient
import Combine

class RaisedHandsStore: NSObject, SyncStoring, ObservableObject {
    struct RaisedHand: Identifiable {
        let userIdentity: String
        var id: String { userIdentity }
        
        init(mapItem: TWSMapItem) {
            userIdentity = mapItem.key
        }
    }

    @Published var raisedHands: [RaisedHand] = []
    @Published var haveNew = false
    private var newRaisedHands: [RaisedHand] = [] {
        didSet {
            haveNew = !newRaisedHands.isEmpty
        }
    }
    var uniqueName: String!
    var errorHandler: ((Error) -> Void)?
    private var map: TWSMap?

    func connect(client: TwilioSyncClient, completion: @escaping (Error?) -> Void) {
        guard let openOptions = TWSOpenOptions.open(withSidOrUniqueName: uniqueName) else { return }

        client.openMap(with: openOptions, delegate: self) { [weak self] result, map in
            guard let self = self else {
                return
            }
            
            guard let map = map else {
                completion(result.error!)
                return
            }
            
            self.map = map

            /// Only fetch the first page because showing more than 100 raised hands is not useful.
            let queryOptions = TWSMapQueryOptions().withPageSize(100)

            map.queryItems(with: queryOptions) { result, paginator in
                guard let paginator = paginator else {
                    completion(result.error!)
                    return
                }

                self.raisedHands = paginator.getItems().map { RaisedHand(mapItem: $0) }
                self.newRaisedHands = self.raisedHands
                completion(nil)
            }
        }
    }
    
    func disconnect() {
        map = nil
        raisedHands = []
        newRaisedHands = []
    }
}

extension RaisedHandsStore: TWSMapDelegate {
    func onMap(_ map: TWSMap, itemAdded item: TWSMapItem, eventContext: TWSEventContext) {
        let raisedHand = RaisedHand(mapItem: item)
        raisedHands.append(raisedHand)
        newRaisedHands.append(raisedHand)
    }
    
    func onMap(
        _ map: TWSMap,
        itemRemovedWithKey itemKey: String,
        previousItemData: [String : Any],
        eventContext: TWSEventContext
    ) {
        raisedHands.removeAll { $0.userIdentity == itemKey }
        newRaisedHands.removeAll { $0.userIdentity == itemKey }
    }
    
    func onMap(_ map: TWSMap, errorOccurred error: TWSError) {
        disconnect()
        errorHandler?(error)
    }
}
