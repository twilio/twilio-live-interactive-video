import React, { createContext, useContext, useReducer, useState } from 'react';
import { initialAppState, appReducer, appStateTypes, appActionTypes } from './appState/appReducer';
import { TwilioError } from 'twilio-video';
import { settingsReducer, initialSettings, Settings, SettingsAction } from './settings/settingsReducer';
import useActiveSinkId from './useActiveSinkId/useActiveSinkId';
import usePasscodeAuth from './usePasscodeAuth/usePasscodeAuth';
import { User } from 'firebase';

export interface StateContextType {
  error: TwilioError | Error | null;
  setError(error: TwilioError | Error | null): void;
  user?: User | null | { displayName: undefined; photoURL: undefined; passcode?: string };
  signIn?(passcode?: string): Promise<void>;
  signOut?(): Promise<void>;
  isAuthReady?: boolean;
  activeSinkId: string;
  setActiveSinkId(sinkId: string): void;
  settings: Settings;
  dispatchSetting: React.Dispatch<SettingsAction>;
  appState: appStateTypes;
  appDispatch: React.Dispatch<appActionTypes>;
}

export const StateContext = createContext<StateContextType>(null!);

export default function AppStateProvider(props: React.PropsWithChildren<{}>) {
  const [error, setError] = useState<TwilioError | null>(null);
  const [activeSinkId, setActiveSinkId] = useActiveSinkId();
  const [settings, dispatchSetting] = useReducer(settingsReducer, initialSettings);
  const [appState, appDispatch] = useReducer(appReducer, initialAppState);

  let contextValue = {
    error,
    setError,
    activeSinkId,
    setActiveSinkId,
    settings,
    dispatchSetting,
    appState,
    appDispatch,
  } as StateContextType;

  contextValue = {
    ...contextValue,
    ...usePasscodeAuth(),
  };

  return <StateContext.Provider value={{ ...contextValue }}>{props.children}</StateContext.Provider>;
}

export function useAppState() {
  const context = useContext(StateContext);
  if (!context) {
    throw new Error('useAppState must be used within the AppStateProvider');
  }
  return context;
}
