import React, { createContext, useEffect, useRef, useState } from 'react';
import SyncClient, { SyncDocument, SyncMap } from 'twilio-sync';
import usePlayerContext from '../../hooks/usePlayerContext/usePlayerContext';
import { useAppState } from '../../state';

type SyncContextType = {
  connect: (token: string) => void;
  registerUserDocument: (token: string) => Promise<void>;
  raisedHandsMap: SyncMap | undefined;
  registerRaisedHandsMap: (token: string) => Promise<void>;
};

export const SyncContext = createContext<SyncContextType>(null!);

export const SyncProvider: React.FC = ({ children }) => {
  const { appDispatch } = useAppState();
  const { player } = usePlayerContext();
  const [raisedHandsMap, setRaisedHandsMap] = useState<SyncMap>();
  const [userDocument, setUserDocument] = useState<SyncDocument>();

  const syncClientRef = useRef<SyncClient>();

  function connect(token: string) {
    syncClientRef.current = new SyncClient(token);
  }

  function registerUserDocument(userDocumentName: string) {
    return syncClientRef.current!.document(userDocumentName).then(document => setUserDocument(document));
  }

  function registerRaisedHandsMap(raisedHandsMapName: string) {
    return syncClientRef.current!.map(raisedHandsMapName).then(map => setRaisedHandsMap(map));
  }

  useEffect(() => {
    // The user can only accept a speaker invite when they are a viewer (when there is a player)
    if (userDocument && player) {
      const handleUpdate = (update: any) => {
        if (typeof update.data.speaker_invite !== 'undefined') {
          appDispatch({ type: 'set-has-speaker-invite', hasSpeakerInvite: update.data.speaker_invite });
        }
      };

      userDocument.on('updated', handleUpdate);
      return () => {
        userDocument.off('updated', handleUpdate);
      };
    }
  }, [userDocument, player, appDispatch]);

  return (
    <SyncContext.Provider value={{ connect, registerUserDocument, raisedHandsMap, registerRaisedHandsMap }}>
      {children}
    </SyncContext.Provider>
  );
};
