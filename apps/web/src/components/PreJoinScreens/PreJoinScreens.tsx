import React, { useState, useEffect } from 'react';
import { ActiveScreen } from '../../state/preJoinState/prejoinReducer';
import { createStream, joinStreamAsSpeaker, joinStreamAsViewer } from '../../state/api/api';
import CreateNewEventScreen from './CreateNewEventScreen/CreateNewEventScreen';
import CreateOrJoinScreen from './CreateOrJoinScreen/CreateOrJoinScreen';
import DeviceSelectionScreen from './DeviceSelectionScreen/DeviceSelectionScreen';
import JoinEventScreen from './JoinEventScreen/JoinEventScreen';
import IntroContainer from '../IntroContainer/IntroContainer';
import { LoadingScreen } from './LoadingScreen/LoadingScreen';
import MediaErrorSnackbar from './MediaErrorSnackbar/MediaErrorSnackbar';
import ParticpantNameScreen from './ParticipantNameScreen/ParticipantNameScreen';
import SpeakerOrViewerScreen from './SpeakerOrViewerScreen/SpeakerOrViewerScreen';
import { useAppState } from '../../state';
import useChatContext from '../../hooks/useChatContext/useChatContext';
import usePlayerContext from '../../hooks/usePlayerContext/usePlayerContext';
import useVideoContext from '../../hooks/useVideoContext/useVideoContext';

export default function PreJoinScreens() {
  const { getAudioAndVideoTracks } = useVideoContext();
  const { connect: chatConnect } = useChatContext();
  const { connect: videoConnect } = useVideoContext();
  const { connect: playerConnect } = usePlayerContext();
  const [mediaError, setMediaError] = useState<Error>();
  const { preJoinState, preJoinDispatch } = useAppState();

  async function connect() {
    preJoinDispatch({ type: 'set-is-loading', isLoading: true });

    try {
      switch (preJoinState.participantType) {
        case 'host': {
          const { data } = await createStream(preJoinState.name, preJoinState.eventName);
          await videoConnect(data.token);
          chatConnect(data.token);

          break;
        }

        case 'speaker': {
          const { data } = await joinStreamAsSpeaker(preJoinState.name, preJoinState.eventName);
          await videoConnect(data.token);
          chatConnect(data.token);

          break;
        }

        case 'viewer': {
          const { data } = await joinStreamAsViewer(preJoinState.name, preJoinState.eventName);
          await playerConnect(data.token);
          // chatConnect(response.data.token);

          break;
        }
      }
      preJoinDispatch({ type: 'set-is-loading', isLoading: false });
    } catch (e) {
      console.log('Error connecting: ', e);
      preJoinDispatch({ type: 'set-is-loading', isLoading: false });
    }
  }

  useEffect(() => {
    if (preJoinState.activeScreen === ActiveScreen.DeviceSelectionScreen && !mediaError) {
      getAudioAndVideoTracks().catch(error => {
        console.log('Error acquiring local media:');
        console.dir(error);
        setMediaError(error);
      });
    }
  }, [getAudioAndVideoTracks, preJoinState.activeScreen, mediaError]);

  return (
    <IntroContainer>
      <MediaErrorSnackbar error={mediaError} />

      {preJoinState.isLoading ? (
        <LoadingScreen />
      ) : (
        {
          [ActiveScreen.ParticipantNameScreen]: (
            <ParticpantNameScreen state={preJoinState} dispatch={preJoinDispatch} />
          ),
          [ActiveScreen.CreateOrJoinScreen]: <CreateOrJoinScreen state={preJoinState} dispatch={preJoinDispatch} />,
          [ActiveScreen.CreateNewEventScreen]: <CreateNewEventScreen state={preJoinState} dispatch={preJoinDispatch} />,
          [ActiveScreen.SpeakerOrViewerScreen]: (
            <SpeakerOrViewerScreen state={preJoinState} dispatch={preJoinDispatch} />
          ),
          [ActiveScreen.JoinEventNameScreen]: (
            <JoinEventScreen state={preJoinState} dispatch={preJoinDispatch} connect={connect} />
          ),
          [ActiveScreen.DeviceSelectionScreen]: (
            <DeviceSelectionScreen state={preJoinState} dispatch={preJoinDispatch} connect={connect} />
          ),
        }[preJoinState.activeScreen]
      )}
    </IntroContainer>
  );
}
