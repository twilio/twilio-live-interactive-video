import React, { ChangeEvent, FormEvent } from 'react';
import { appActionTypes, ActiveScreen, appStateTypes } from '../../../state/appState/appReducer';
import { Typography, makeStyles, TextField, Grid, Button, InputLabel, Theme } from '@material-ui/core';

const useStyles = makeStyles((theme: Theme) => ({
  gutterBottom: {
    fontWeight: 'bold',
    marginBottom: '1em',
  },
  welcome: {
    color: '#606B85',
    marginBottom: '0.3em',
    fontWeight: 'bold',
  },
  askName: {
    fontWeight: 'bold',
    marginBottom: '2.3em',
    color: '#606B85',
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

interface ParticipantNameScreenProps {
  state: appStateTypes;
  dispatch: React.Dispatch<appActionTypes>;
}

export default function ParticipantNameScreen({ state, dispatch }: ParticipantNameScreenProps) {
  const classes = useStyles();

  const handleNameChange = (event: ChangeEvent<HTMLInputElement>) => {
    dispatch({ type: 'set-participant-name', participantName: event.target.value });
  };

  const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    dispatch({ type: 'set-active-screen', activeScreen: ActiveScreen.CreateOrJoinScreen });
  };

  return (
    <div>
      <Typography variant="h5" className={classes.welcome}>
        Welcome to:
      </Typography>
      <Typography variant="h4" className={classes.gutterBottom}>
        Twilio Live Video Events
      </Typography>
      <Typography variant="body1" className={classes.askName}>
        What's your name?
      </Typography>
      <form onSubmit={handleSubmit}>
        <div className={classes.inputContainer}>
          <div className={classes.textFieldContainer}>
            <InputLabel
              htmlFor="input-user-name"
              style={{ fontWeight: 'bold', fontSize: '0.8rem', marginBottom: '0.5em' }}
            >
              Full Name
            </InputLabel>
            <TextField
              id="input-user-name"
              autoFocus
              variant="outlined"
              fullWidth
              size="small"
              value={state.participantName}
              onChange={handleNameChange}
            />
          </div>
        </div>
        <Grid container justifyContent="flex-end">
          <Button
            variant="contained"
            type="submit"
            color="primary"
            disabled={!state.participantName}
            className={classes.continueButton}
          >
            Continue
          </Button>
        </Grid>
      </form>
    </div>
  );
}
