import React, { useState, useEffect } from 'react';
import { ActiveScreen } from '../../state/appState/appReducer';
import { createStream, joinStreamAsSpeaker, joinStreamAsViewer } from '../../state/api/api';
import CreateNewEventScreen from './CreateNewEventScreen/CreateNewEventScreen';
import CreateOrJoinScreen from './CreateOrJoinScreen/CreateOrJoinScreen';
import DeviceSelectionScreen from './DeviceSelectionScreen/DeviceSelectionScreen';
import JoinEventScreen from './JoinEventScreen/JoinEventScreen';
import IntroContainer from '../IntroContainer/IntroContainer';
import { LoadingScreen } from './LoadingScreen/LoadingScreen';
import MediaErrorSnackbar from './MediaErrorSnackbar/MediaErrorSnackbar';
import ParticipantNameScreen from './ParticipantNameScreen/ParticipantNameScreen';
import SpeakerOrViewerScreen from './SpeakerOrViewerScreen/SpeakerOrViewerScreen';
import { useAppState } from '../../state';
import useChatContext from '../../hooks/useChatContext/useChatContext';
import usePlayerContext from '../../hooks/usePlayerContext/usePlayerContext';
import useVideoContext from '../../hooks/useVideoContext/useVideoContext';
import useSyncContext from '../../hooks/useSyncContext/useSyncContext';

export default function PreJoinScreens() {
  const { getAudioAndVideoTracks } = useVideoContext();
  const { connect: chatConnect } = useChatContext();
  const { connect: videoConnect } = useVideoContext();
  const { connect: playerConnect, disconnect: playerDisconnect } = usePlayerContext();
  const { connect: syncConnect, registerViewerDocument, registerRaisedHandsMap } = useSyncContext();
  const [mediaError, setMediaError] = useState<Error>();
  const { appState, appDispatch } = useAppState();

  async function connect() {
    appDispatch({ type: 'set-is-loading', isLoading: true });

    try {
      if (appState.hasSpeakerInvite) {
        const { data } = await joinStreamAsSpeaker(appState.participantName, appState.eventName);
        await videoConnect(data.token);
        chatConnect(data.token);
        registerRaisedHandsMap(data.sync_object_names.raised_hands_map);
        playerDisconnect();
        appDispatch({ type: 'set-is-loading', isLoading: false });
        appDispatch({ type: 'set-has-speaker-invite', hasSpeakerInvite: false });
        return;
      }

      switch (appState.participantType) {
        case 'host': {
          const { data } = await createStream(appState.participantName, appState.eventName);
          syncConnect(data.token);
          await videoConnect(data.token);
          registerRaisedHandsMap(data.sync_object_names.raised_hands_map);
          chatConnect(data.token);
          break;
        }

        case 'speaker': {
          const { data } = await joinStreamAsSpeaker(appState.participantName, appState.eventName);
          syncConnect(data.token);
          await videoConnect(data.token);
          registerRaisedHandsMap(data.sync_object_names.raised_hands_map);
          chatConnect(data.token);
          break;
        }

        case 'viewer': {
          const { data } = await joinStreamAsViewer(appState.participantName, appState.eventName);
          syncConnect(data.token);
          await playerConnect(data.token);
          registerViewerDocument(data.sync_object_names.viewer_document);
          // chatConnect(data.token);
          break;
        }
      }
      appDispatch({ type: 'set-is-loading', isLoading: false });
    } catch (e) {
      console.log('Error connecting: ', e);
      appDispatch({ type: 'set-is-loading', isLoading: false });
    }
  }

  useEffect(() => {
    if (appState.activeScreen === ActiveScreen.DeviceSelectionScreen && !mediaError) {
      getAudioAndVideoTracks().catch(error => {
        console.log('Error acquiring local media:');
        console.dir(error);
        setMediaError(error);
      });
    }
  }, [getAudioAndVideoTracks, appState.activeScreen, mediaError]);

  return (
    <IntroContainer transparentBackground={appState.hasSpeakerInvite}>
      <MediaErrorSnackbar error={mediaError} />

      {appState.isLoading ? (
        <LoadingScreen />
      ) : (
        {
          [ActiveScreen.ParticipantNameScreen]: <ParticipantNameScreen state={appState} dispatch={appDispatch} />,
          [ActiveScreen.CreateOrJoinScreen]: <CreateOrJoinScreen state={appState} dispatch={appDispatch} />,
          [ActiveScreen.CreateNewEventScreen]: <CreateNewEventScreen state={appState} dispatch={appDispatch} />,
          [ActiveScreen.SpeakerOrViewerScreen]: <SpeakerOrViewerScreen state={appState} dispatch={appDispatch} />,
          [ActiveScreen.JoinEventNameScreen]: (
            <JoinEventScreen state={appState} dispatch={appDispatch} connect={connect} />
          ),
          [ActiveScreen.DeviceSelectionScreen]: (
            <DeviceSelectionScreen state={appState} dispatch={appDispatch} connect={connect} />
          ),
        }[appState.activeScreen]
      )}
    </IntroContainer>
  );
}
