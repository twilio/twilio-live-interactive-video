import { produce } from 'immer';
import CreateOrJoinScreen from './CreateOrJoinScreen/CreateOrJoinScreen';

export enum ActiveScreen {
  ParticipantNameScreen,
  CreateOrJoinScreen,
  CreateNewEventScreen,
  SpeakerOrViewerScreen,
  JoinEventNameScreen,
  DeviceSelectionScreen,
}

export type actionTypes =
  | { type: 'set-active-screen'; activeScreen: ActiveScreen }
  | { type: 'set-name'; name: string }
  | { type: 'set-participant-type'; participantType: stateType['participantType'] }
  | { type: 'set-event-name'; eventName: string };

export interface stateType {
  activeScreen: ActiveScreen;
  participantType: 'host' | 'speaker' | 'viewer' | null;
  name: string;
  eventName: string;
  mediaError: Error | null;
}

export const initialState: stateType = {
  activeScreen: ActiveScreen.ParticipantNameScreen,
  participantType: null,
  name: '',
  eventName: '',
  mediaError: null,
};

export const preJoinScreenReducer = produce((draft: stateType, action: actionTypes) => {
  switch (action.type) {
    case 'set-name':
      draft.name = action.name;
      break;

    case 'set-event-name':
      draft.eventName = action.eventName;
      break;

    case 'set-active-screen':
      draft.activeScreen = action.activeScreen;
      break;

    case 'set-participant-type':
      draft.participantType = action.participantType;
      switch (action.participantType) {
        case 'host':
          draft.activeScreen = ActiveScreen.CreateNewEventScreen;
          break;
        case 'speaker':
        case 'viewer':
          draft.activeScreen = ActiveScreen.JoinEventNameScreen;
          break;
        case null:
          draft.activeScreen = ActiveScreen.SpeakerOrViewerScreen;
          break;
      }

      break;
  }
});
