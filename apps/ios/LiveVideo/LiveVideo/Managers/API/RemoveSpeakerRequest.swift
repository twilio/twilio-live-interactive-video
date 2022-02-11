//
//  Copyright (C) 2021 Twilio, Inc.
//

struct RemoveSpeakerRequest: APIRequest {
    struct Parameters: Encodable {
        let roomName: String
        let userIdentity: String
    }

    struct Response: Decodable {
        let removed: Bool
    }

    let path = "remove-speaker"
    let parameters: Parameters
    let responseType = Response.self
    
    init(roomName: String, userIdentity: String) {
        parameters = Parameters(roomName: roomName, userIdentity: userIdentity)
    }
}
