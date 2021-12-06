import React from 'react';
import ReactDOM from 'react-dom';

import { CssBaseline } from '@material-ui/core';
import { MuiThemeProvider } from '@material-ui/core/styles';
import { Theme } from '@twilio-paste/core/theme';

import App from './App';
import AppStateProvider, { useAppState } from './state';
import { HashRouter as Router, Redirect, Route, Switch } from 'react-router-dom';
import ErrorDialog from './components/ErrorDialog/ErrorDialog';
import LoginPage from './components/LoginPage/LoginPage';
import PrivateRoute from './components/PrivateRoute/PrivateRoute';
import theme from './theme';
import './types';
import { ChatProvider } from './components/ChatProvider';
import { PlayerProvider } from './components/PlayerProvider';
import { VideoProvider } from './components/VideoProvider';
import useConnectionOptions from './utils/useConnectionOptions/useConnectionOptions';
import UnsupportedBrowserWarning from './components/UnsupportedBrowserWarning/UnsupportedBrowserWarning';
import { SyncProvider } from './components/SyncProvider';
import { SnackbarProvider } from './components/Snackbar/SnackbarProvider';

// Here we redirect the user to a URL with a hash. This maintains backwards-compatibility with URLs
// like https://my-twilio-video-app.com/room/test-room, which will be redirected to https://my-twilio-video-app.com/#/room/test-room
if (!window.location.hash) {
  window.history.replaceState(null, '', '/#' + window.location.pathname + window.location.search);
}

const VideoApp = () => {
  const { error, setError } = useAppState();
  const connectionOptions = useConnectionOptions();

  return (
    <SnackbarProvider>
      <VideoProvider options={connectionOptions} onError={setError}>
        <ErrorDialog dismissError={() => setError(null)} error={error} />
        <PlayerProvider>
          <ChatProvider>
            <SyncProvider>
              <App />
            </SyncProvider>
          </ChatProvider>
        </PlayerProvider>
      </VideoProvider>
    </SnackbarProvider>
  );
};

ReactDOM.render(
  <MuiThemeProvider theme={theme}>
    <CssBaseline />
    <Theme.Provider theme="default">
      <UnsupportedBrowserWarning>
        <Router basename="/">
          <AppStateProvider>
            <Switch>
              <PrivateRoute exact path="/">
                <VideoApp />
              </PrivateRoute>
              <PrivateRoute path="/:ViewerType/:EventName">
                <VideoApp />
              </PrivateRoute>
              <Route path="/login">
                <LoginPage />
              </Route>
              <Route>
                <Redirect to="/" />
              </Route>
            </Switch>
          </AppStateProvider>
        </Router>
      </UnsupportedBrowserWarning>
    </Theme.Provider>
  </MuiThemeProvider>,
  document.getElementById('root')
);
