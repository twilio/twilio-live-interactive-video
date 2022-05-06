//
//  Copyright (C) 2022 Twilio, Inc.
//

import TwilioConversationsClient

struct ChatMessage: Identifiable {
    let id: String
    let author: String
    let date: Date
    let body: String

    init?(message: TCHMessage) {
        guard
            let sid = message.sid,
            let date = message.dateCreatedAsDate,
            let author = message.author,
            let body = message.body
        else {
            return nil
        }

        id = sid
        self.author = author
        self.date = date
        self.body = body
    }
}
