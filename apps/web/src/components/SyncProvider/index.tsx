import React, { createContext, useEffect, useRef, useState } from 'react';
import { SyncClient, SyncDocument, SyncMap } from 'twilio-sync';
import usePlayerContext from '../../hooks/usePlayerContext/usePlayerContext';
import { useAppState } from '../../state';

type SyncContextType = {
  connect: (token: string) => void;
  disconnect: () => void;
  registerUserDocument: (userDocumentName: string) => Promise<void>;
  raisedHandsMap: SyncMap | undefined;
  speakersMap: SyncMap | undefined;
  viewersMap: SyncMap | undefined;
  registerSyncMaps: (syncObjectNames: SyncObjectNames) => void;
};

type SyncObjectNames = {
  speakers_map: string;
  viewers_map: string;
  raised_hands_map: string;
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
    let syncOptions;
    if (process.env.REACT_APP_TWILIO_ENVIRONMENT) {
      syncOptions = { region: `${process.env.REACT_APP_TWILIO_ENVIRONMENT}-us1` };
    }
    syncClientRef.current = new SyncClient(token, syncOptions);
  }

  function disconnect() {
    if (syncClientRef.current) {
      setRaisedHandsMap(undefined);
      setSpeakersMap(undefined);
      setViewersMap(undefined);
      setUserDocument(undefined);
      syncClientRef.current.shutdown();
    }
  }

  function registerUserDocument(userDocumentName: string) {
    return syncClientRef.current!.document(userDocumentName).then(document => setUserDocument(document));
  }

  function registerSyncMaps({ speakers_map, viewers_map, raised_hands_map }: SyncObjectNames) {
    const syncClient = syncClientRef.current!;
    syncClient.map(raised_hands_map).then(map => setRaisedHandsMap(map));
    syncClient.map(speakers_map).then(map => setSpeakersMap(map));
    syncClient.map(viewers_map).then(map => setViewersMap(map));
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
        disconnect,
        registerUserDocument,
        raisedHandsMap,
        speakersMap,
        viewersMap,
        registerSyncMaps,
      }}
    >
      {children}
    </SyncContext.Provider>
  );
};
