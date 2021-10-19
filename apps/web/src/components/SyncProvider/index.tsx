import React, { createContext, useRef, useState } from 'react';
import SyncClient, { SyncMap } from 'twilio-sync';
import { useAppState } from '../../state';

type SyncContextType = {
  connect: (token: string) => void;
  registerViewerDocument: (token: string) => Promise<void>;
  raisedHandsMap: SyncMap | undefined;
  registerRaisedHandsMap: (token: string) => Promise<void>;
};

export const SyncContext = createContext<SyncContextType>(null!);

export const SyncProvider: React.FC = ({ children }) => {
  const { appDispatch } = useAppState();
  const [raisedHandsMap, setRaisedHandsMap] = useState<SyncMap>();

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

  function registerRaisedHandsMap(raisedHandsMapName: string) {
    return syncClientRef.current!.map(raisedHandsMapName).then(map => {
      setRaisedHandsMap(map);
    });
  }

  return (
    <SyncContext.Provider value={{ connect, registerViewerDocument, raisedHandsMap, registerRaisedHandsMap }}>
      {children}
    </SyncContext.Provider>
  );
};
