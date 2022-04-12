import React, { useEffect, useRef, useState, useLayoutEffect } from 'react';
import clsx from 'clsx';
import { createStyles, makeStyles, Theme } from '@material-ui/core/styles';
import { Player as TwilioPlayer } from '@twilio/live-player-sdk';
import PlayerMenuBar from './PlayerMenuBar/PlayerMenuBar';
import ParticipantWindow from '../ParticipantWindow/ParticipantWindow';
import usePlayerContext from '../../hooks/usePlayerContext/usePlayerContext';
import { useAppState } from '../../state';
import { useEnqueueSnackbar } from '../../hooks/useSnackbar/useSnackbar';
import { usePlayerState } from '../../hooks/usePlayerState/usePlayerState';
import useIsRecording from '../../hooks/useIsRecording/useIsRecording';
import { Tooltip, Typography } from '@material-ui/core';

TwilioPlayer.telemetry.subscribe(data => {
  const method = data.name === 'error' ? 'error' : 'log';
  console[method](`[${data.type}.${data.name}] => ${JSON.stringify(data)}`);
});

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    container: {
      position: 'relative',
      background: 'black',
      height: '100%',
      display: 'grid',
      gridTemplateRows: '100%',
      paddingBottom: `${theme.footerHeight}px`, // Leave some space for the footer
    },
    rightDrawerOpen: { gridTemplateColumns: `1fr ${theme.rightDrawerWidth}px` },
    video: {
      width: '100%',
      height: '100%',
    },
    recordingIndicator: {
      position: 'absolute',
      bottom: 0,
      display: 'flex',
      alignItems: 'center',
      background: 'rgba(0, 0, 0, 0.5)',
      color: 'white',
      padding: '0.1em 0.3em 0.1em 0',
      fontSize: '1.2rem',
      height: '28px',
      [theme.breakpoints.down('sm')]: {
        bottom: 'auto',
        right: 0,
        top: 0,
      },
    },
    circle: {
      height: '12px',
      width: '12px',
      background: 'red',
      borderRadius: '100%',
      margin: '0 0.6em',
      animation: `1.25s $pulsate ease-out infinite`,
    },
  })
);

function Player() {
  const classes = useStyles();
  const videoElRef = useRef<HTMLVideoElement>(null!);
  const { player, disconnect } = usePlayerContext();
  const state = usePlayerState();
  const { appState, appDispatch } = useAppState();
  const enqueueSnackbar = useEnqueueSnackbar();
  const [welcomeMessageDisplayed, setWelcomeMessageDisplayed] = useState(false);
  const { isRecording } = useIsRecording();

  useLayoutEffect(() => {
    if (player && state === 'ready') {
      appDispatch({ type: 'set-is-loading', isLoading: false });

      player.attach(videoElRef.current);
      player.play();
    }
  }, [player, appDispatch, state]);

  useEffect(() => {
    if (!welcomeMessageDisplayed) {
      setWelcomeMessageDisplayed(true);
      enqueueSnackbar({
        headline: 'Welcome!',
        message:
          "You're now in the audience - you'll be unable to share audio or video. Raise your hand at any time to request to speak.",
        variant: 'info',
      });
    }
  }, [enqueueSnackbar, welcomeMessageDisplayed]);

  return (
    <div style={{ height: '100vh' }}>
      <div
        className={clsx(classes.container, {
          [classes.rightDrawerOpen]: appState.isParticipantWindowOpen,
        })}
      >
        {isRecording && (
          <Tooltip title="This live stream is being recorded by the host." placement="top">
            <div className={classes.recordingIndicator}>
              <div className={classes.circle}></div>
              <Typography variant="body1" color="inherit" data-cy-recording-indicator>
                Recording
              </Typography>
            </div>
          </Tooltip>
        )}
        <video className={classes.video} ref={videoElRef} playsInline></video>
        <ParticipantWindow />
      </div>
      <PlayerMenuBar roomName={appState.eventName} disconnect={disconnect} />
    </div>
  );
}

export default React.memo(Player);
