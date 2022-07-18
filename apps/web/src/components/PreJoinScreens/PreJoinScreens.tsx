import React, { useState, useEffect } from 'react';
import { ActiveScreen } from '../../state/appState/appReducer';
import { createStream, joinStreamAsSpeaker, joinStreamAsViewer, connectViewerToPlayer } from '../../state/api/api';
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
import { useEnqueueSnackbar } from '../../hooks/useSnackbar/useSnackbar';
import usePlayerContext from '../../hooks/usePlayerContext/usePlayerContext';
import useVideoContext from '../../hooks/useVideoContext/useVideoContext';
import useSyncContext from '../../hooks/useSyncContext/useSyncContext';
import { isMobile } from '../../utils';

export default function PreJoinScreens() {
  const { getAudioAndVideoTracks } = useVideoContext();
  const { connect: chatConnect, setIsChatWindowOpen } = useChatContext();
  const { connect: videoConnect } = useVideoContext();
  const { connect: playerConnect, disconnect: playerDisconnect } = usePlayerContext();
  const { connect: syncConnect, registerUserDocument, registerSyncMaps } = useSyncContext();
  const [mediaError, setMediaError] = useState<Error>();
  const { appState, appDispatch } = useAppState();
  const enqueueSnackbar = useEnqueueSnackbar();

  async function connect() {
    appDispatch({ type: 'set-is-loading', isLoading: true });
    try {
      if (appState.hasSpeakerInvite) {
        const { data } = await joinStreamAsSpeaker(appState.participantName, appState.eventName);
        await videoConnect(data.token);
        if (data.chat_enabled) {
          chatConnect(data.token, data.room_sid);
          appDispatch({ type: 'set-is-chat-enabled', isChatEnabled: true });
          if (!isMobile) setIsChatWindowOpen(true);
        }
        registerSyncMaps(data.sync_object_names);
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
          registerSyncMaps(data.sync_object_names);
          if (data.chat_enabled) {
            chatConnect(data.token, data.room_sid);
            appDispatch({ type: 'set-is-chat-enabled', isChatEnabled: true });
            if (!isMobile) setIsChatWindowOpen(true);
          }
          break;
        }
        case 'speaker': {
          const { data } = await joinStreamAsSpeaker(appState.participantName, appState.eventName);
          syncConnect(data.token);
          await videoConnect(data.token);
          registerSyncMaps(data.sync_object_names);
          if (data.chat_enabled) {
            chatConnect(data.token, data.room_sid);
            appDispatch({ type: 'set-is-chat-enabled', isChatEnabled: true });
            if (!isMobile) setIsChatWindowOpen(true);
          }
          break;
        }
        case 'viewer': {
          const { data } = await joinStreamAsViewer(appState.participantName, appState.eventName);
          syncConnect(data.token);
          await playerConnect(data.token);
          registerUserDocument(data.sync_object_names.user_document);
          registerSyncMaps(data.sync_object_names);
          await connectViewerToPlayer(appState.participantName, appState.eventName);
          if (data.chat_enabled) {
            chatConnect(data.token, data.room_sid);
            appDispatch({ type: 'set-is-chat-enabled', isChatEnabled: true });
            if (!isMobile) setIsChatWindowOpen(true);
          }
          break;
        }
      }
      appDispatch({ type: 'set-is-loading', isLoading: false });
    } catch (e) {
      console.log('Error connecting: ', e.toJSON ? e.toJSON() : e);
      appDispatch({ type: 'set-is-loading', isLoading: false });
      if (e.response?.data?.error?.explanation === 'Room exists') {
        enqueueSnackbar({
          headline: 'Error',
          message: 'An event already exists with that name. Try creating an event with a different name.',
          variant: 'error',
        });
      } else if (e.response?.data?.error?.message === 'error finding room') {
        enqueueSnackbar({
          headline: 'Error',
          message: 'Event cannot be found. Please check the event name and try again.',
          variant: 'error',
        });
      } else {
        enqueueSnackbar({
          headline: 'Error',
          message: 'There was an error while connecting to the event.',
          variant: 'error',
        });
      }
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
        <LoadingScreen state={appState} />
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
