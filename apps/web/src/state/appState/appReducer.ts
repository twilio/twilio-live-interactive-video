import { produce } from 'immer';

export enum ActiveScreen {
  ParticipantNameScreen,
  CreateOrJoinScreen,
  CreateNewEventScreen,
  SpeakerOrViewerScreen,
  JoinEventNameScreen,
  DeviceSelectionScreen,
}

export type appActionTypes =
  | { type: 'set-active-screen'; activeScreen: ActiveScreen }
  | { type: 'set-participant-name'; participantName: string }
  | { type: 'set-participant-type'; participantType: appStateTypes['participantType'] }
  | { type: 'set-event-name'; eventName: string }
  | { type: 'set-is-loading'; isLoading: boolean }
  | { type: 'set-has-speaker-invite'; hasSpeakerInvite: boolean }
  | { type: 'reset-state' }
  | { type: 'set-is-participant-window-open'; isParticipantWindowOpen: boolean };

export interface appStateTypes {
  activeScreen: ActiveScreen;
  participantType: 'host' | 'speaker' | 'viewer' | null;
  participantName: string;
  eventName: string;
  mediaError: Error | null;
  isLoading: boolean;
  hasSpeakerInvite: boolean;
  isParticipantWindowOpen: boolean;
}

export const initialAppState: appStateTypes = {
  activeScreen: ActiveScreen.ParticipantNameScreen,
  participantType: null,
  participantName: '',
  eventName: '',
  mediaError: null,
  isLoading: false,
  hasSpeakerInvite: false,
  isParticipantWindowOpen: false,
};

export const appReducer = produce((draft: appStateTypes, action: appActionTypes) => {
  switch (action.type) {
    case 'set-participant-name':
      draft.participantName = action.participantName;
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

    case 'set-has-speaker-invite':
      // Ignore this action when connecting to a room
      if (!draft.isLoading) {
        draft.hasSpeakerInvite = action.hasSpeakerInvite;
        if (action.hasSpeakerInvite) {
          draft.activeScreen = ActiveScreen.DeviceSelectionScreen;
        }
      }
      break;

    case 'reset-state':
      return initialAppState;

    case 'set-is-participant-window-open':
      draft.isParticipantWindowOpen = action.isParticipantWindowOpen;
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
