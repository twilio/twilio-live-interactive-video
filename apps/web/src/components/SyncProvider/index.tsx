import React, { createContext, useEffect, useRef, useState } from 'react';
import { SyncClient, SyncDocument, SyncMap } from 'twilio-sync';
import usePlayerContext from '../../hooks/usePlayerContext/usePlayerContext';
import { useAppState } from '../../state';

type SyncContextType = {
  connect: (token: string) => void;
  registerUserDocument: (userDocumentName: string) => Promise<void>;
  raisedHandsMap: SyncMap | undefined;
  registerRaisedHandsMap: (raisedHandsMapName: string) => Promise<void>;
  registerSpeakersMap: (speakersMapName: string) => Promise<void>;
  speakersMap: SyncMap | undefined;
  registerViewersMap: (viewersMapName: string) => Promise<void>;
  viewersMap: SyncMap | undefined;
};

export const SyncContext = createContext<SyncContextType>(null!);

export const SyncProvider: React.FC = ({ children }) => {
  const { appDispatch } = useAppState();
  const { player } = usePlayerContext();
  const [raisedHandsMap, setRaisedHandsMap] = useState<SyncMap>();
  const [speakersMap, setSpeakersMap] = useState<SyncMap>();
  const [viewersMap, setViewersMap] = useState<SyncMap>();
  const [userDocument, setUserDocument] = useState<SyncDocument>();

  const syncClientRef = useRef<SyncClient>();

  function connect(token: string) {
    syncClientRef.current = new SyncClient(token);
  }

  function registerSpeakersMap(speakersMapName: string) {
    return syncClientRef.current!.map(speakersMapName).then(map => setSpeakersMap(map));
  }

  function registerUserDocument(userDocumentName: string) {
    return syncClientRef.current!.document(userDocumentName).then(document => setUserDocument(document));
  }

  function registerRaisedHandsMap(raisedHandsMapName: string) {
    return syncClientRef.current!.map(raisedHandsMapName).then(map => setRaisedHandsMap(map));
  }

  function registerViewersMap(viewersMapName: string) {
    return syncClientRef.current!.map(viewersMapName).then(map => setViewersMap(map));
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
    <SyncContext.Provider
      value={{
        connect,
        registerUserDocument,
        raisedHandsMap,
        registerRaisedHandsMap,
        registerSpeakersMap,
        speakersMap,
        registerViewersMap,
        viewersMap,
      }}
    >
      {children}
    </SyncContext.Provider>
  );
};
