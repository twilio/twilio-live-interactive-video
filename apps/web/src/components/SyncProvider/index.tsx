import React, { createContext, useRef } from 'react';
import SyncClient from 'twilio-sync';
import useVideoContext from '../../hooks/useVideoContext/useVideoContext';
import { useAppState } from '../../state';

type SyncContextType = {
  connect: (token: string) => void;
  registerViewerDocument: (token: string) => Promise<void>;
};

export const SyncContext = createContext<SyncContextType>(null!);

export const SyncProvider: React.FC = ({ children }) => {
  // const { connect: videoConnect, onError } = useVideoContext();
  const { appDispatch } = useAppState();

  const syncClientRef = useRef<SyncClient>();

  function connect(token: string) {
    syncClientRef.current = new SyncClient(token);
  }

  function registerViewerDocument(viewerDocumentName: string) {
    return syncClientRef.current!.document(viewerDocumentName).then(document => {
      document.on('updated', update => {
        if (typeof update.data.speaker_invite !== 'undefined') {
          appDispatch({ type: 'set-has-speaker-invite', hasSpeakerInvite: update.data.speaker_invite });
        }
      });
    });
  }

  return <SyncContext.Provider value={{ connect, registerViewerDocument }}>{children}</SyncContext.Provider>;
};
