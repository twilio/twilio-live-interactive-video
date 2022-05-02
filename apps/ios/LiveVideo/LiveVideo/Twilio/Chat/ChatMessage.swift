//
//  Copyright (C) 2022 Twilio, Inc.
//

import TwilioConversationsClient

struct ChatMessage: Identifiable {
    let id: String
    let author: String
    let dateCreated: Date
    let body: String

    init?(message: TCHMessage) {
        guard
            let sid = message.sid,
            let dateCreated = message.dateCreatedAsDate,
            let author = message.author,
            let body = message.body
        else {
            return nil
        }

        id = sid
        self.author = author
        self.dateCreated = dateCreated
        self.body = body
    }
}
