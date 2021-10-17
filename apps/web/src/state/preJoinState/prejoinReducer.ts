import { produce } from 'immer';

export enum ActiveScreen {
  ParticipantNameScreen,
  CreateOrJoinScreen,
  CreateNewEventScreen,
  SpeakerOrViewerScreen,
  JoinEventNameScreen,
  DeviceSelectionScreen,
}

export type preJoinActionTypes =
  | { type: 'set-active-screen'; activeScreen: ActiveScreen }
  | { type: 'set-name'; name: string }
  | { type: 'set-participant-type'; participantType: preJoinStateType['participantType'] }
  | { type: 'set-event-name'; eventName: string }
  | { type: 'set-is-loading'; isLoading: boolean };

export interface preJoinStateType {
  activeScreen: ActiveScreen;
  participantType: 'host' | 'speaker' | 'viewer' | null;
  name: string;
  eventName: string;
  mediaError: Error | null;
  isLoading: boolean;
}

export const initialPreJoinState: preJoinStateType = {
  activeScreen: ActiveScreen.ParticipantNameScreen,
  participantType: null,
  name: '',
  eventName: '',
  mediaError: null,
  isLoading: false,
};

export const preJoinScreenReducer = produce((draft: preJoinStateType, action: preJoinActionTypes) => {
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

    case 'set-is-loading':
      draft.isLoading = action.isLoading;
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
