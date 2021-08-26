//
//  Copyright (C) 2021 Twilio, Inc.
//

import Foundation

protocol APIRequest {
    associatedtype Parameters: Encodable
    associatedtype Response: Decodable
    var path: String { get }
    var parameters: Parameters { get }
    var responseType: Response.Type { get }
}
