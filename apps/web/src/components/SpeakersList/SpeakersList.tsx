import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import { Typography } from '@material-ui/core';
import { useSpeakersMap } from '../../hooks/useSpeakersMap/useSpeakersMap';

const useStyles = makeStyles({
  header: {
    fontWeight: 'bold',
    padding: '0 1em',
  },
  speakersContainer: {
    padding: '0.4em 1em',
    '& p': {
      padding: '0.5em 0',
    },
  },
});

export default function SpeakersList() {
  const { speakers } = useSpeakersMap();

  const classes = useStyles();

  return (
    <>
      <div className={classes.header}>{`Speakers (${speakers.length})`}</div>

      <div className={classes.speakersContainer}>
        {speakers.map(speaker => (
          <>
            <Typography key={speaker} variant="body1">
              {speaker}
            </Typography>
          </>
        ))}
      </div>
    </>
  );
}
