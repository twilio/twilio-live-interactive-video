//
//  Copyright (C) 2021 Twilio, Inc.
//

import TwilioSyncClient
import Combine

class RaisedHandsStore: NSObject, SyncStoring {
    struct RaisedHand {
        let userIdentity: String
        
        init(mapItem: TWSMapItem) {
            userIdentity = mapItem.key
        }
    }
    
    let raisedHandAddedPublisher = PassthroughSubject<RaisedHand, Never>()
    let raisedHandRemovedPublisher = PassthroughSubject<RaisedHand, Never>()
    var uniqueName: String!
    var errorHandler: ((Error) -> Void)?
    private(set) var raisedHands: [RaisedHand] = []
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
        let raisedHand = RaisedHand(mapItem: item)
        raisedHands.append(raisedHand)
        raisedHandAddedPublisher.send(raisedHand)
    }
    
    func onMap(
        _ map: TWSMap,
        itemRemovedWithKey itemKey: String,
        previousItemData: [String : Any],
        eventContext: TWSEventContext
    ) {
        guard let index = raisedHands.firstIndex(where: { $0.userIdentity == itemKey }) else {
            return
        }

        let raisedHand = raisedHands[index]
        raisedHands.remove(at: index)
        raisedHandRemovedPublisher.send(raisedHand)
    }
    
    func onMap(_ map: TWSMap, errorOccurred error: TWSError) {
        disconnect()
        errorHandler?(error)
    }
}
