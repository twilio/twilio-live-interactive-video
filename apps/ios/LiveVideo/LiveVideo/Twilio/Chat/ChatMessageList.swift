//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI

struct ChatMessageList: View {
    @EnvironmentObject var chatManager: ChatManager
    @State private var isFirstLoadComplete = false

    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(chatManager.messages) { message in
                        VStack(alignment: .leading) {
                            ChatHeaderView(author: message.author, date: message.date)
                            ChatBubbleView(messageBody: message.body)
                        }
                        .padding()
                        .id(message.id) /// So we can programmatically scroll to this view
                    }
                }
            }
            .onChange(of: chatManager.hasUnreadMessage) { hasUnreadMessage in
                guard hasUnreadMessage else {
                    return
                }
                
                withAnimation(isFirstLoadComplete ? .default : nil) {
                    scrollViewProxy.scrollTo(chatManager.messages.last?.id)
                }

                isFirstLoadComplete = true
                chatManager.hasUnreadMessage = false
            }
            .onAppear {
                UIScrollView.appearance().keyboardDismissMode = .interactive

                DispatchQueue.main.async {
                    /// This is a hack so that after the view is loaded we scroll to the bottom
                    chatManager.hasUnreadMessage = true
                }
            }
        }
    }
}

struct ChatMessageList_Previews: PreviewProvider {
    static var previews: some View {
        ChatMessageList()
            .environmentObject(ChatManager.stub())
    }
}

extension ChatManager {
    static func stub(messages: [ChatMessage] = [.stub()]) -> ChatManager {
        ChatManager(messages: messages)
    }
}

extension ChatMessage {
    static func stub(
        id: String = UUID().uuidString,
        author: String = "Bob",
        date: Date = Date(),
        body: String = "Message"
    ) -> ChatMessage {
        ChatMessage(id: id, author: author, date: date, body: body)
    }
    
    private init(id: String, author: String, date: Date, body: String) {
        self.id = id
        self.author = author
        self.date = date
        self.body = body
    }
}
