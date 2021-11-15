//
//  Copyright (C) 2021 Twilio, Inc.
//

import TwilioSyncClient
import Combine

/// Reusable store that fetches users from a sync map.
///
/// Set `uniqueName` to specify the name of the sync map to fetch users from.
class SyncUsersStore: NSObject, SyncStoring {
    struct User: Identifiable {
        let identity: String
        var id: String { identity }
     
        init(mapItem: TWSMapItem) {
            identity = mapItem.key
        }
    }

    let userAddedPublisher = PassthroughSubject<User, Never>()
    let userRemovedPublisher = PassthroughSubject<User, Never>()
    var uniqueName: String!
    var errorHandler: ((Error) -> Void)?
    private(set) var users: [User] = []
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

            /// Only fetch the first page because showing more than 100 is not useful for this app
            let queryOptions = TWSMapQueryOptions().withPageSize(100)

            map.queryItems(with: queryOptions) { result, paginator in
                guard let paginator = paginator else {
                    completion(result.error!)
                    return
                }

                self.users = paginator.getItems().map { User(mapItem: $0) }
                completion(nil)
            }
        }
    }
    
    func disconnect() {
        map = nil
        users = []
    }
}

extension SyncUsersStore: TWSMapDelegate {
    func onMap(_ map: TWSMap, itemAdded item: TWSMapItem, eventContext: TWSEventContext) {
        let user = User(mapItem: item)
        users.append(user)
        userAddedPublisher.send(user)
    }
    
    func onMap(
        _ map: TWSMap,
        itemRemovedWithKey itemKey: String,
        previousItemData: [String : Any],
        eventContext: TWSEventContext
    ) {
        guard let index = users.firstIndex(where: { $0.identity == itemKey }) else {
            return
        }

        let user = users[index]
        users.remove(at: index)
        userRemovedPublisher.send(user)
    }
    
    func onMap(_ map: TWSMap, errorOccurred error: TWSError) {
        disconnect()
        errorHandler?(error)
    }
}
