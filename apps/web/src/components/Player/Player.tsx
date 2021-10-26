import React, { useEffect, useRef, useState } from 'react';
import { createStyles, makeStyles, Theme } from '@material-ui/core/styles';
import { Player as TwilioPlayer } from '@twilio/player-sdk';
import PlayerMenuBar from './PlayerMenuBar/PlayerMenuBar';
import usePlayerContext from '../../hooks/usePlayerContext/usePlayerContext';
import { useAppState } from '../../state';
import { useEnqueueSnackbar } from '../../hooks/useSnackbar/useSnackbar';
import { usePlayerState } from '../../hooks/usePlayerState/usePlayerState';

TwilioPlayer.telemetry.subscribe(data => {
  const method = data.name === 'error' ? 'error' : 'log';
  console[method](`[${data.type}.${data.name}] => ${JSON.stringify(data)}`);
});

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    container: {
      background: 'black',
      height: '100%',
      paddingBottom: `${theme.footerHeight}px`, // Leave some space for the footer
    },
    video: {
      width: '100%',
      height: '100%',
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

  useEffect(() => {
    if (player) {
      // if (player?.state === 'idle') {
      //   player.attach(videoElRef.current);
      //   player.play();
      // }
      console.log('state1', state);
      if (state === 'ready') {
        console.log('state2', state);
        appDispatch({ type: 'set-is-loading', isLoading: false });
        player.attach(videoElRef.current);
        player.play();
      }
    }
  }, [player, appDispatch, state]);

  useEffect(() => {
    console.log('meage', welcomeMessageDisplayed);
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
      <div className={classes.container}>
        <video className={classes.video} ref={videoElRef} playsInline autoPlay></video>
      </div>
      <PlayerMenuBar roomName={appState.eventName} disconnect={disconnect} />
    </div>
  );
}

export default React.memo(Player);
