import React, { useState, useEffect, FormEvent, useReducer } from 'react';
import DeviceSelectionScreen from './DeviceSelectionScreen/DeviceSelectionScreen';
import IntroContainer from '../IntroContainer/IntroContainer';
import MediaErrorSnackbar from './MediaErrorSnackbar/MediaErrorSnackbar';
import RoomNameScreen from './JoinEventScreen/JoinEventScreen';
import { useAppState } from '../../state';
import { useHistory, useLocation, useParams } from 'react-router-dom';
import useVideoContext from '../../hooks/useVideoContext/useVideoContext';
import { ActiveScreen, initialState, preJoinScreenReducer } from './prejoinReducer';
import ParticipantTracks from '../ParticipantTracks/ParticipantTracks';
import ParticpantNameScreen from './ParticipantNameScreen/ParticipantNameScreen';
import CreateOrJoinScreen from './CreateOrJoinScreen/CreateOrJoinScreen';
import CreateNewEventScreen from './CreateNewEventScreen/CreateNewEventScreen';
import SpeakerOrViewerScreen from './SpeakerOrViewerScreen/SpeakerOrViewerScreen';
import JoinEventScreen from './JoinEventScreen/JoinEventScreen';

export enum HostSteps {
  createNewEventStep,
  invitePeopleStep,
  deviceSelectionStep,
}

export enum SpeakerOrViewerSteps {
  speakerOrViewerStep,
  eventNameStep,
  deviceSelectionStep,
}

export default function PreJoinScreens() {
  const { getAudioAndVideoTracks } = useVideoContext();
  const { URLRoomName } = useParams();
  const [state, dispatch] = useReducer(preJoinScreenReducer, initialState);
  // const location = useLocation();
  // const history = useHistory();

  const [mediaError, setMediaError] = useState<Error>();

  // useEffect(() => {
  //   if (URLRoomName) {
  //     setRoomName(URLRoomName);
  //   }
  // }, [user, URLRoomName]);

  // useEffect(() => {
  //   if (step === Steps.deviceSelectionStep && !mediaError) {
  //     getAudioAndVideoTracks().catch(error => {
  //       console.log('Error acquiring local media:');
  //       console.dir(error);
  //       setMediaError(error);
  //     });
  //   }
  // }, [getAudioAndVideoTracks, step, mediaError]);

  // const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
  //   event.preventDefault();
  //   history.replace(`/room/${roomName}${location.search}`);
  //   setStep(Steps.deviceSelectionStep);
  // };

  return (
    <IntroContainer>
      <MediaErrorSnackbar error={mediaError} />
      {
        {
          [ActiveScreen.ParticipantNameScreen]: <ParticpantNameScreen state={state} dispatch={dispatch} />,
          [ActiveScreen.CreateOrJoinScreen]: <CreateOrJoinScreen state={state} dispatch={dispatch} />,
          [ActiveScreen.CreateNewEventScreen]: <CreateNewEventScreen state={state} dispatch={dispatch} />,
          [ActiveScreen.SpeakerOrViewerScreen]: <SpeakerOrViewerScreen state={state} dispatch={dispatch} />,
          [ActiveScreen.JoinEventNameScreen]: <JoinEventScreen state={state} dispatch={dispatch} />,
          [ActiveScreen.DeviceSelectionScreen]: <DeviceSelectionScreen state={state} dispatch={dispatch} />,
        }[state.activeScreen]
      }
    </IntroContainer>
  );
}
