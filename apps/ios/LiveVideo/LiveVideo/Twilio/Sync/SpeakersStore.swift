//
//  Copyright (C) 2021 Twilio, Inc.
//

import TwilioSyncClient

class SpeakersStore: NSObject {
    struct Speaker {
        let userIdentity: String
        let isHost: Bool
        
        init(mapItem: TWSMapItem) {
            userIdentity = mapItem.key
            isHost = mapItem.data["host"] as? Bool ?? false
        }
    }

    private(set) var speakers: [Speaker] = []
    private var map: TWSMap?

    func connect(client: TwilioSyncClient, mapName: String, completion: @escaping (Error?) -> Void) {
        guard let openOptions = TWSOpenOptions.open(withSidOrUniqueName: mapName) else { return }

        client.openMap(with: openOptions, delegate: self) { [weak self] result, map in
            if let error = result.error {
                completion(error)
                return
            }
            
            self?.map = map

            let queryOptions = TWSMapQueryOptions()

            map?.queryItems(with: queryOptions) { result, paginator in
                if let error = result.error {
                    completion(error)
                    return
                }

                self?.speakers = paginator?.getItems().map { Speaker(mapItem: $0) } ?? []
                completion(nil)
            }
        }
    }
}

/// No need to handle updates at this time because we are only using host which does not change.
extension SpeakersStore: TWSMapDelegate {
    
}
