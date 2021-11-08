//
//  Copyright (C) 2021 Twilio, Inc.
//

import TwilioSyncClient
import Combine

class ViewersStore: NSObject, SyncStoring, ObservableObject {
    struct Viewer {
        let userIdentity: String
        
        init(mapItem: TWSMapItem) {
            userIdentity = mapItem.key
        }
    }

    let viewerAddedPublisher = PassthroughSubject<Viewer, Never>()
    let viewerRemovedPublisher = PassthroughSubject<Viewer, Never>()
    private(set) var viewers: [Viewer] = []
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

            /// Only fetch the first page because showing details for more than 100 viewers is not useful.
            let queryOptions = TWSMapQueryOptions().withPageSize(100)

            map.queryItems(with: queryOptions) { result, paginator in
                guard let paginator = paginator else {
                    completion(result.error!)
                    return
                }

                self.viewers = paginator.getItems().map { Viewer(mapItem: $0) }
                completion(nil)
            }
        }
    }
    
    func disconnect() {
        map = nil
        viewers = []
    }
}

extension ViewersStore: TWSMapDelegate {
    func onMap(_ map: TWSMap, itemAdded item: TWSMapItem, eventContext: TWSEventContext) {
        let viewer = Viewer(mapItem: item)
        viewers.append(viewer)
        viewerAddedPublisher.send(viewer)
    }
    
    func onMap(
        _ map: TWSMap,
        itemRemovedWithKey itemKey: String,
        previousItemData: [String : Any],
        eventContext: TWSEventContext
    ) {
        guard let index = viewers.firstIndex(where: { $0.userIdentity == itemKey }) else {
            return
        }
        
        let viewer = viewers[index]
        viewers.remove(at: index)
        viewerRemovedPublisher.send(viewer)
    }
    
    func onMap(_ map: TWSMap, errorOccurred error: TWSError) {
        disconnect()
        errorHandler?(error)
    }
}
