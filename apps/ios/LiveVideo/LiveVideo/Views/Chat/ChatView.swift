//
//  Copyright (C) 2022 Twilio, Inc.
//

import SwiftUI

struct ChatView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ChatMessageList()
                Divider()
                ChatInputBar()
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
            .environmentObject(ChatManager.stub(messages: [.stub(author: "Bob"), .stub(author: "Alice")]))
            .environmentObject(AuthManager.stub(userIdentity: "Bob"))
    }
}
