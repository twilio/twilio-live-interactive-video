//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI

struct ChatMessageList: View {
    @EnvironmentObject var chatManager: ChatManager
    @EnvironmentObject var authManager: AuthManager
    @State private var isFirstLoadComplete = false

    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                LazyVStack {
                    ForEach(chatManager.messages) { message in
                        VStack(spacing: 9) {
                            ChatHeaderView(
                                author: message.author,
                                isAuthorYou: message.author == authManager.userIdentity,
                                date: message.date
                            )
                            ChatBubbleView(
                                messageBody: message.body,
                                isAuthorYou: message.author == authManager.userIdentity
                            )
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 7)
                    }
                    
                    Spacer(minLength: 6)
                        .id("bottom") /// So we can programmatically scroll to this view
                }
            }
            .onChange(of: chatManager.hasUnreadMessage) { hasUnreadMessage in
                guard hasUnreadMessage else {
                    return
                }
                
                withAnimation(isFirstLoadComplete ? .default : nil) {
                    scrollView.scrollTo("bottom")
                }

                isFirstLoadComplete = true
                chatManager.hasUnreadMessage = false
            }
            .onAppear {
                UIScrollView.appearance().keyboardDismissMode = .interactive

                /// Must do this async so that initial scroll to bottom works. This seems like
                /// an Apple bug since people on the web say it used to just work.
                DispatchQueue.main.async {
                    /// A convenient way to make the list scroll to the most recent messages at the bottom
                    chatManager.hasUnreadMessage = true
                }
            }
        }
    }
}

struct ChatMessageList_Previews: PreviewProvider {
    static var previews: some View {
        ChatMessageList()
            .environmentObject(ChatManager.stub(messages: [.stub(author: "Bob"), .stub(author: "Alice")]))
            .environmentObject(AuthManager.stub(userIdentity: "Bob"))
    }
}

extension ChatManager {
    static func stub(messages: [ChatMessage] = []) -> ChatManager {
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
