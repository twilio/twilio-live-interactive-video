//
//  Copyright (C) 2021 Twilio, Inc.
//

import TwilioSyncClient

protocol SyncObjectConnecting: AnyObject {
    var errorHandler: ((Error) -> Void)? { get set }
    func connect(client: TwilioSyncClient, completion: @escaping (Error?) -> Void)
    func disconnect()
}
