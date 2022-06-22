import React, { createContext, useCallback, useEffect, useRef, useState } from 'react';
import { Client } from '@twilio/conversations';
import { Conversation } from '@twilio/conversations/lib/conversation';
import { Message } from '@twilio/conversations/lib/message';
import useVideoContext from '../../hooks/useVideoContext/useVideoContext';

type ChatContextType = {
  isChatWindowOpen: boolean;
  setIsChatWindowOpen: (isChatWindowOpen: boolean) => void;
  connect: (token: string, roomSid: string) => void;
  disconnect: () => void;
  hasUnreadMessages: boolean;
  messages: Message[];
  conversation: Conversation | null;
};

export const ChatContext = createContext<ChatContextType>(null!);

export const ChatProvider: React.FC = ({ children }) => {
  const { onError } = useVideoContext();
  const isChatWindowOpenRef = useRef(false);
  const [isChatWindowOpen, setIsChatWindowOpen] = useState(false);
  const [conversation, setConversation] = useState<Conversation | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [hasUnreadMessages, setHasUnreadMessages] = useState(false);
  const [videoRoomSid, setVideoRoomSid] = useState('');
  const [chatClient, setChatClient] = useState<Client>();

  const connect = useCallback(
    (token: string, roomSid: string) => {
      if (!chatClient) {
        setVideoRoomSid(roomSid);
        let conversationOptions;

        if (process.env.REACT_APP_TWILIO_ENVIRONMENT) {
          conversationOptions = { region: `${process.env.REACT_APP_TWILIO_ENVIRONMENT}-us1` };
        }
        Client.create(token, conversationOptions)
          .then(client => {
            //@ts-ignore
            window.chatClient = client;
            setChatClient(client);
          })
          .catch(e => {
            console.error(e);
            onError(new Error("There was a problem connecting to Twilio's conversation service."));
          });
      }
    },
    [onError, chatClient]
  );

  const disconnect = useCallback(() => {
    setChatClient(undefined);
    chatClient?.shutdown();
  }, [chatClient]);

  useEffect(() => {
    if (conversation) {
      const handleMessageAdded = (message: Message) => setMessages(oldMessages => [...oldMessages, message]);
      conversation.getMessages().then(newMessages => setMessages(newMessages.items));
      conversation.on('messageAdded', handleMessageAdded);
      return () => {
        conversation.off('messageAdded', handleMessageAdded);
      };
    }
  }, [conversation]);

  useEffect(() => {
    // If the chat window is closed and there are new messages, set hasUnreadMessages to true
    if (!isChatWindowOpenRef.current && messages.length) {
      setHasUnreadMessages(true);
    }
  }, [messages]);

  useEffect(() => {
    isChatWindowOpenRef.current = isChatWindowOpen;
    if (isChatWindowOpen) setHasUnreadMessages(false);
  }, [isChatWindowOpen]);

  useEffect(() => {
    if (videoRoomSid && chatClient) {
      chatClient
        .getConversationByUniqueName(videoRoomSid)
        .then(newConversation => {
          //@ts-ignore
          window.chatConversation = newConversation;
          setConversation(newConversation);
        })
        .catch(e => {
          console.error(e);
          onError(new Error('There was a problem getting the Conversation associated with this room.'));
        });
    }
  }, [chatClient, onError, videoRoomSid]);

  return (
    <ChatContext.Provider
      value={{ isChatWindowOpen, setIsChatWindowOpen, connect, disconnect, hasUnreadMessages, messages, conversation }}
    >
      {children}
    </ChatContext.Provider>
  );
};
