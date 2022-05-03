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
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading) { // TODO: Use LazyVStack
                            ForEach(chatManager.messages) { message in
                                VStack(alignment: .leading) {
                                    Text(message.author)
                                        .foregroundColor(.textWeak)
                                    
                                    HStack {
                                        Text(message.body)
                                            .padding(10)
                                            .background(Color.backgroundPrimaryWeaker)
                                            .cornerRadius(20)
                                        Spacer()
                                    }
                                }
                                .padding()
                                .id(message.id)
                            }

                            Spacer()
                                .frame(height: 1)
                                .id("bottom")
                        }
                        .onChange(of: chatManager.hasUnreadMessage) { value in
                            if value {
                                withAnimation {
                                    proxy.scrollTo(chatManager.messages.last?.id)
                                }
                                chatManager.hasUnreadMessage = false
                            }
                        }
                        .onAppear {
                            proxy.scrollTo(chatManager.messages.last?.id)
                        }
                    }
                }
                
                Divider()
                
                HStack {
                    TextField("Write a message...", text: $messageText)
                    
                    // TODO: Disable when there is no text
                    Button {
                        chatManager.sendMessage(messageText)
                        messageText = ""
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
            .onAppear {
                UIScrollView.appearance().keyboardDismissMode = .interactive
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
    static func stub(messages: [ChatMessage] = [.stub(), .stub()]) -> ChatManager {
        ChatManager(messages: messages)
    }
}

extension ChatMessage {
    static func stub(
        id: String = UUID().uuidString,
        author: String = "Bob",
        dateCreated: Date = Date(),
        body: String = "Message"
    ) -> ChatMessage {
        ChatMessage(id: id, author: author, dateCreated: dateCreated, body: body)
    }
    
    private init(id: String, author: String, dateCreated: Date, body: String) {
        self.id = id
        self.author = author
        self.dateCreated = dateCreated
        self.body = body
    }
}






extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
