import React, { useEffect, useRef } from 'react';
import { Player as TwilioPlayer } from '@twilio/player-sdk';
import { createStyles, makeStyles, Theme } from '@material-ui/core/styles';
import PlayerMenuBar from './PlayerMenuBar/PlayerMenuBar';
import usePlayerContext from '../../hooks/usePlayerContext/usePlayerContext';
import { useAppState } from '../../state';

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

export default function Player() {
  const classes = useStyles();
  const videoElRef = useRef<HTMLVideoElement>(null!);
  const { player, disconnect } = usePlayerContext();
  const { preJoinState } = useAppState();

  useEffect(() => {
    player!.attach(videoElRef.current);
    player!.play();
  }, [player]);

  return (
    <div style={{ height: '100vh' }}>
      <div className={classes.container}>
        <video className={classes.video} ref={videoElRef}></video>
      </div>
      <PlayerMenuBar roomName={preJoinState.eventName} disconnect={disconnect} />
    </div>
  );
}
