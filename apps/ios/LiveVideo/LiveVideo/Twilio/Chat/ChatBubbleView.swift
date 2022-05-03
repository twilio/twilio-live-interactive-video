//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI

struct ChatBubbleView: View {
    let message: String
    
    var body: some View {
        HStack {
            Text(message)
                .padding(10)
                .background(Color.backgroundPrimaryWeaker)
                .cornerRadius(20)
            Spacer()
        }
    }
}

struct ChatBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        ChatBubbleView(message: "Message")
    }
}
