//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var chatManager: ChatManager
    @Environment(\.presentationMode) var presentationMode
    @State private var messageText = ""

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(chatManager.messages) { message in
                        VStack(alignment: .leading) {
                            Text(message.body)
                            Text(message.author)
                            Text(message.dateCreated, style: .time)
                        }
                    }
                }
                .listStyle(.plain)

                HStack {
                    TextField("Write a message...", text: $messageText)
                    
                    Button("Send") {
                        chatManager.sendMessage(messageText)
                        messageText = ""
                    }
                }
                .padding()
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
            .environmentObject(ChatManager.stub())
    }
}

extension ChatManager {
    static func stub(messages: [ChatMessage] = [.stub()]) -> ChatManager {
        let chatManager = ChatManager()
        chatManager.messages = messages
        return chatManager
    }
}

extension ChatMessage {
    static func stub(body: String = "Message", author: String = "Bob") -> ChatMessage {
        var message = ChatMessage()
        message.body = body
        message.author = author
        return message
    }
}
