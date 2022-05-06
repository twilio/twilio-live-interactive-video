//
//  Copyright (C) 2022 Twilio, Inc.
//

import TwilioConversationsClient

class ChatManager: NSObject, ObservableObject {
    @Published var hasUnreadMessage = false
    @Published private(set) var messages: [ChatMessage] = []
    private var client: TwilioConversationsClient?
    private var conversation: TCHConversation?
    private var conversationName = ""
    private var appSettingsManager: AppSettingsManager!

    init(messages: [ChatMessage] = []) {
        self.messages = messages
    }
    
    func configure(appSettingsManager: AppSettingsManager) {
        self.appSettingsManager = appSettingsManager
    }

    func connect(accessToken: String, conversationName: String) {
        self.conversationName = conversationName
        
        let properties = TwilioConversationsClientProperties()
        
        if let region = appSettingsManager.environment.region {
            properties.region = region /// Only used by Twilio employees for internal testing
        }
        
        TwilioConversationsClient.conversationsClient(
            withToken: accessToken,
            properties: properties,
            delegate: self
        ) { _, client in
            self.client = client
        }
    }

    func disconnect() {
        client?.shutdown()
        client = nil
        conversation = nil
        messages = []
        hasUnreadMessage = false
    }

    func sendMessage(_ message: String) {
        conversation?.prepareMessage().setBody(message).buildAndSend(completion: nil)
    }

    private func getConversation() {
        client?.conversation(withSidOrUniqueName: conversationName) { [weak self] _, conversation in
            self?.conversation = conversation
            self?.getMessages()
        }
    }
    
    private func getMessages() {
        /// Just get the last 100 messages since the UI does not have pagination in this app
        conversation?.getLastMessages(withCount: 100) { [weak self] _, messages in
            guard let messages = messages else {
                return
            }
            
            self?.messages = messages.compactMap { ChatMessage(message: $0) }
            
            if !messages.isEmpty {
                self?.hasUnreadMessage = true
            }
        }
    }
}

extension ChatManager: TwilioConversationsClientDelegate {
    func conversationsClient(
        _ client: TwilioConversationsClient,
        synchronizationStatusUpdated status: TCHClientSynchronizationStatus
    ) {
        switch status {
        case .started, .conversationsListCompleted:
            return
        case .completed:
            getConversation()
        case .failed:
            disconnect()
        @unknown default:
            return
        }
    }
    
    func conversationsClient(
        _ client: TwilioConversationsClient,
        conversation: TCHConversation,
        messageAdded message: TCHMessage
    ) {
        guard conversation.sid == self.conversation?.sid, let message = ChatMessage(message: message) else {
            return
        }

        messages.append(message)
        hasUnreadMessage = true
    }
}
