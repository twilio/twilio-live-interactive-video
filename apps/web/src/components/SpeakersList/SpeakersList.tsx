import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import { Typography } from '@material-ui/core';
import { SpeakerMenu } from './SpeakerMenu/SpeakerMenu';
import { useSpeakersMap } from '../../hooks/useSpeakersMap/useSpeakersMap';
import useVideoContext from '../../hooks/useVideoContext/useVideoContext';

const useStyles = makeStyles({
  header: {
    fontWeight: 'bold',
    padding: '0.8em 0',
  },
  speakersListContainer: {
    padding: '0.4em 1em',
    overflow: 'auto',
    maxHeight: 'calc(50% - 56px)', //participantWindowHeader is 56px
    borderBottom: '0.1em solid #CACDD8',
    '& p': {
      padding: '0.5em 0',
    },
  },
  speakerContainer: {
    display: 'flex',
    justifyContent: 'space-between',
    width: '100%',
    alignItems: 'center',
  },
});

export default function SpeakersList() {
  const { host, speakers } = useSpeakersMap();
  const { room } = useVideoContext();
  const localParticipant = room?.localParticipant;

  const classes = useStyles();

  return (
    <div className={classes.speakersListContainer}>
      <div className={classes.header}>{`Speakers (${speakers.length})`}</div>
      <Typography variant="body1">{`${host} (Host)`}</Typography>

      {speakers
        .filter(speaker => speaker !== host)
        .map(speaker => (
          <div key={speaker} className={classes.speakerContainer}>
            <Typography variant="body1">{speaker}</Typography>
            {localParticipant?.identity === host && <SpeakerMenu />}
          </div>
        ))}
    </div>
  );
}
