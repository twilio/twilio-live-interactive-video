import React from 'react';
import { appActionTypes, ActiveScreen, appStateTypes } from '../../../state/appState/appReducer';
import { Typography, makeStyles, Grid, Button, Theme } from '@material-ui/core';

const useStyles = makeStyles((theme: Theme) => ({
  gutterBottom: {
    marginBottom: '1em',
  },
  inputContainer: {
    display: 'flex',
    justifyContent: 'space-between',
    margin: '1.5em 0 3.5em',
    '& div:not(:last-child)': {
      marginRight: '1em',
    },
    [theme.breakpoints.down('sm')]: {
      margin: '1.5em 0 2em',
    },
  },
  textFieldContainer: {
    width: '100%',
  },
  continueButton: {
    [theme.breakpoints.down('sm')]: {
      width: '100%',
    },
  },
}));

interface SpeakerOrViewerScreenProps {
  state: appStateTypes;
  dispatch: React.Dispatch<appActionTypes>;
}

export default function SpeakerOrViewerScreen({ state, dispatch }: SpeakerOrViewerScreenProps) {
  const classes = useStyles();

  return (
    <>
      <Typography variant="h5" className={classes.gutterBottom}>
        Speaker or Viewer?
      </Typography>
      <Typography variant="body1">
        Do you plan on chatting up the room or are you more of the quiet, mysterious audience type?
      </Typography>

      <Grid container justifyContent="space-between">
        <Button
          onClick={() => dispatch({ type: 'set-participant-type', participantType: 'speaker' })}
          variant="contained"
          color="primary"
          disabled={!state.name}
          className={classes.continueButton}
        >
          Join as Speaker
        </Button>
        <Button
          onClick={() => dispatch({ type: 'set-participant-type', participantType: 'viewer' })}
          variant="contained"
          color="primary"
          disabled={!state.name}
          className={classes.continueButton}
        >
          Join as Viewer
        </Button>
        <Button
          onClick={() => dispatch({ type: 'set-active-screen', activeScreen: ActiveScreen.CreateOrJoinScreen })}
          variant="contained"
          color="primary"
          disabled={!state.name}
          className={classes.continueButton}
        >
          Go Back
        </Button>
      </Grid>
    </>
  );
}
