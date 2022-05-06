//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI

struct ChatBubbleView: View {
    let messageBody: String
    let isAuthorYou: Bool
    
    var body: some View {
        HStack {
            Text(messageBody)
                .padding(10)
                .background(isAuthorYou ? Color.backgroundPrimaryWeaker : Color.backgroundStrong)
                .cornerRadius(20)
            Spacer()
        }
    }
}

struct ChatBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChatBubbleView(messageBody: "Message that I sent", isAuthorYou: true)
            ChatBubbleView(messageBody: "Message that someone else sent", isAuthorYou: false)
            ChatBubbleView(messageBody: "Message that is really long and does not fit on a single line", isAuthorYou: true)
        }
        .previewLayout(.sizeThatFits)
    }
}
