import React, { ChangeEvent, FormEvent } from 'react';
import { Typography, makeStyles, TextField, Grid, Button, InputLabel, Theme } from '@material-ui/core';
import { actionTypes, ActiveScreen, stateType } from '../prejoinReducer';

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

interface CreateOrJoinScreenProps {
  state: stateType;
  dispatch: React.Dispatch<actionTypes>;
}

export default function CreateOrJoinScreen({ state, dispatch }: CreateOrJoinScreenProps) {
  const classes = useStyles();

  return (
    <>
      <Typography variant="h5" className={classes.gutterBottom}>
        Create or Join?
      </Typography>
      <Typography variant="body1">Create your own event or join one that's already happening</Typography>

      <Grid container justifyContent="space-between">
        <Button
          onClick={() => dispatch({ type: 'set-participant-type', participantType: 'host' })}
          variant="contained"
          color="primary"
          disabled={!state.name}
          className={classes.continueButton}
        >
          Create a New Event
        </Button>
        <Button
          onClick={() => dispatch({ type: 'set-participant-type', participantType: null })}
          variant="contained"
          color="primary"
          disabled={!state.name}
          className={classes.continueButton}
        >
          Join an Event
        </Button>
        <Button
          onClick={() => dispatch({ type: 'set-active-screen', activeScreen: ActiveScreen.ParticipantNameScreen })}
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
