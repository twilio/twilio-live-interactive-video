import React, { useEffect, useRef } from 'react';
import { useParams } from 'react-router-dom';
import { Player as TwilioPlayer } from '@twilio/player-sdk';
import { createStyles, makeStyles, Theme } from '@material-ui/core/styles';
import PlayerMenuBar from './PlayerMenuBar/PlayerMenuBar';

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
  const { URLRoomName } = useParams();
  const videoElRef = useRef<HTMLVideoElement>(null!);

  useEffect(() => {
    if (URLRoomName) {
      const { protocol, host } = window.location;

      fetch('/stream-token', {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
        },
        body: JSON.stringify({ room_name: URLRoomName, user_identity: 'Player' }),
      })
        .then(res => res.json())
        .then(res =>
          TwilioPlayer.connect(res.token, {
            playerWasmAssetsPath: `${protocol}//${host}/player`,
          })
        )
        .then(player => {
          player.attach(videoElRef.current!);
          player.play();
        });
    }
  }, [URLRoomName]);

  return (
    <div style={{ height: '100%' }}>
      <div className={classes.container}>
        <video className={classes.video} ref={videoElRef}></video>
      </div>
      <PlayerMenuBar roomName={URLRoomName} />
    </div>
  );
}
