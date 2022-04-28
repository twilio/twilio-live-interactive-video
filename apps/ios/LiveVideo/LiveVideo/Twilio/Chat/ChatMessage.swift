//
//  Copyright (C) 2022 Twilio, Inc.
//

import TwilioConversationsClient

struct ChatMessage: Identifiable {
    var id: String
    var author: String
    var dateCreated: Date
    var body: String
    
    init() {
        id = UUID().uuidString
        author = ""
        dateCreated = Date()
        body = ""
    }

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
