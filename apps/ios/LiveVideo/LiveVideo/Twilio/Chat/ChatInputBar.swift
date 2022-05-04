//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI

struct ChatInputBar: View {
    @EnvironmentObject var chatManager: ChatManager
    @State var messageBody = ""
    
    var body: some View {
        HStack {
            TextField("Write a message...", text: $messageBody)
            
            Button {
                chatManager.sendMessage(messageBody)
                messageBody = ""
            } label: {
                Image(systemName: "paperplane")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .cornerRadius(4)
                    .frame(height: 44)
            }
            .disabled(messageBody.isEmpty)
        }
        .padding(8)
    }
}

struct ChatInputBar_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChatInputBar()
                .previewDisplayName("Empty")
            ChatInputBar(messageBody: "Hello")
                .previewDisplayName("Not empty")
        }
        .previewLayout(.sizeThatFits)
    }
}
