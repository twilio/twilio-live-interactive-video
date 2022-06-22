import React, { useEffect, useRef, useState, useLayoutEffect } from 'react';
import clsx from 'clsx';
import { createStyles, makeStyles, Theme } from '@material-ui/core/styles';
import { Player as TwilioPlayer } from '@twilio/live-player-sdk';
import PlayerMenuBar from './PlayerMenuBar/PlayerMenuBar';
import ParticipantWindow from '../ParticipantWindow/ParticipantWindow';
import ChatWindow from '../ChatWindow/ChatWindow';
import usePlayerContext from '../../hooks/usePlayerContext/usePlayerContext';
import { useAppState } from '../../state';
import { useEnqueueSnackbar } from '../../hooks/useSnackbar/useSnackbar';
import { usePlayerState } from '../../hooks/usePlayerState/usePlayerState';
import useChatContext from '../../hooks/useChatContext/useChatContext';

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
  })
);

function Player() {
  const classes = useStyles();
  const videoElRef = useRef<HTMLVideoElement>(null!);
  const { player, disconnect } = usePlayerContext();
  const { isChatWindowOpen } = useChatContext();
  const state = usePlayerState();
  const { appState, appDispatch } = useAppState();
  const enqueueSnackbar = useEnqueueSnackbar();
  const [welcomeMessageDisplayed, setWelcomeMessageDisplayed] = useState(false);

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
          [classes.rightDrawerOpen]: appState.isParticipantWindowOpen || isChatWindowOpen,
        })}
      >
        <video className={classes.video} ref={videoElRef} playsInline></video>
        <ParticipantWindow />
        <ChatWindow />
      </div>
      <PlayerMenuBar roomName={appState.eventName} disconnect={disconnect} />
    </div>
  );
}

export default React.memo(Player);
