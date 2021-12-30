import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import { Typography } from '@material-ui/core';
import { useSpeakersMap } from '../../hooks/useSpeakersMap/useSpeakersMap';

const useStyles = makeStyles({
  header: {
    fontWeight: 'bold',
    padding: '1em 1em 0',
  },
  speakersContainer: {
    padding: '0.4em 1em',
    borderBottom: '0.1em solid #CACDD8',
    '& p': {
      padding: '0.5em 0',
    },
  },
});

export default function SpeakersList() {
  const { host, speakers } = useSpeakersMap();

  const classes = useStyles();

  return (
    <>
      <div className={classes.header}>{`Speakers (${speakers.length})`}</div>

      <div className={classes.speakersContainer}>
        <Typography variant="body1">{`${host} (Host, you)`}</Typography>
        {speakers
          .filter(speaker => speaker !== host)
          .map(speaker => (
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
