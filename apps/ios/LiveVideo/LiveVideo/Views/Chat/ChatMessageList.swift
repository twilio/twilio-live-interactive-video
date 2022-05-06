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
            .onChange(of: isFirstLoadComplete) { _ in
                scrollView.scrollTo("bottom")
            }
            .onChange(of: chatManager.messages.count) { count in
                withAnimation {
                    scrollView.scrollTo("bottom")
                }

                chatManager.hasUnreadMessage = false
            }
            .onAppear {
                UIScrollView.appearance().keyboardDismissMode = .interactive
                chatManager.hasUnreadMessage = false
                
                /// Must use an extra step so that initial scroll to bottom works. We should be able to perform the scroll right
                /// here directly but I think there is an Apple bug. People on the web said it used to work but not anymore.
                isFirstLoadComplete = true
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
