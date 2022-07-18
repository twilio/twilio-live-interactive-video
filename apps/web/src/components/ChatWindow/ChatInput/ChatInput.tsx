import React, { useEffect, useRef, useState } from 'react';
import { Button, Grid, makeStyles } from '@material-ui/core';
import clsx from 'clsx';
import { Conversation } from '@twilio/conversations/lib/conversation';
import { isMobile } from '../../../utils';
import SendMessageIcon from '../../../icons/SendMessageIcon';
import Snackbar from '../../Snackbar/Snackbar';
import TextareaAutosize from '@material-ui/core/TextareaAutosize';

const useStyles = makeStyles(theme => ({
  chatInputContainer: {
    borderTop: '1px solid #e4e7e9',
    borderBottom: '1px solid #e4e7e9',
    padding: '1em 1.2em 1em',
  },
  textArea: {
    width: '100%',
    border: '0',
    resize: 'none',
    fontSize: '14px',
    fontFamily: 'Inter',
    outline: 'none',
  },
  button: {
    padding: '0.56em',
    minWidth: 'auto',
    '&:disabled': {
      background: 'none',
      '& path': {
        fill: '#d8d8d8',
      },
    },
  },
  buttonContainer: {
    margin: '1em 0 0 1em',
    display: 'flex',
  },
  textAreaContainer: {
    display: 'flex',
    marginTop: '0.4em',
    padding: '0.48em 0.7em',
    border: '2px solid transparent',
  },
  isTextareaFocused: {
    borderColor: theme.palette.primary.main,
    borderRadius: '4px',
  },
}));

interface ChatInputProps {
  conversation: Conversation;
  isChatWindowOpen: boolean;
}

export default function ChatInput({ conversation, isChatWindowOpen }: ChatInputProps) {
  const classes = useStyles();
  const [messageBody, setMessageBody] = useState('');
  const [fileSendError, setFileSendError] = useState<string | null>(null);
  const isValidMessage = /\S/.test(messageBody);
  const textInputRef = useRef<HTMLTextAreaElement>(null);
  const [isTextareaFocused, setIsTextareaFocused] = useState(false);

  useEffect(() => {
    if (isChatWindowOpen) {
      // When the chat window is opened, we will focus on the text input.
      // This is so the user doesn't have to click on it to begin typing a message.
      textInputRef.current?.focus();
    }
  }, [isChatWindowOpen]);

  const handleChange = (event: React.ChangeEvent<HTMLTextAreaElement>) => {
    setMessageBody(event.target.value);
  };

  // ensures pressing enter + shift creates a new line, so that enter on its own only sends the message:
  const handleReturnKeyPress = (event: React.KeyboardEvent) => {
    if (!isMobile && event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      handleSendMessage(messageBody);
    }
  };

  const handleSendMessage = (message: string) => {
    if (isValidMessage) {
      conversation.sendMessage(message.trim());
      setMessageBody('');
    }
  };

  return (
    <div className={classes.chatInputContainer}>
      <Snackbar
        open={Boolean(fileSendError)}
        headline="Error"
        message={fileSendError || ''}
        variant="error"
        handleClose={() => setFileSendError(null)}
      />
      <div className={clsx(classes.textAreaContainer, { [classes.isTextareaFocused]: isTextareaFocused })}>
        {/* 
        Here we add the "isTextareaFocused" class when the user is focused on the TextareaAutosize component.
        This helps to ensure a consistent appearance across all browsers. Adding padding to the TextareaAutosize
        component does not work well in Firefox. See: https://github.com/twilio/twilio-video-app-react/issues/498
        */}
        <TextareaAutosize
          minRows={1}
          maxRows={3}
          className={classes.textArea}
          aria-label="chat input"
          placeholder="Write a message..."
          onKeyPress={handleReturnKeyPress}
          onChange={handleChange}
          value={messageBody}
          data-cy-chat-input
          ref={textInputRef}
          onFocus={() => setIsTextareaFocused(true)}
          onBlur={() => setIsTextareaFocused(false)}
        />
      </div>

      <Grid container alignItems="flex-end" justifyContent="flex-end" wrap="nowrap">
        <div className={classes.buttonContainer}>
          <Button
            className={classes.button}
            onClick={() => handleSendMessage(messageBody)}
            color="primary"
            variant="contained"
            disabled={!isValidMessage}
            data-cy-send-message-button
          >
            <SendMessageIcon />
          </Button>
        </div>
      </Grid>
    </div>
  );
}
