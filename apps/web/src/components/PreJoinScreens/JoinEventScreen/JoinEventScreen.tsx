import React, { ChangeEvent, FormEvent } from 'react';
import { appActionTypes, ActiveScreen, appStateTypes } from '../../../state/appState/appReducer';
import { Typography, makeStyles, TextField, Grid, Button, InputLabel, Theme } from '@material-ui/core';

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

interface JoinEventScreenProps {
  state: appStateTypes;
  dispatch: React.Dispatch<appActionTypes>;
  connect: () => void;
}

export default function JoinEventScreen({ state, dispatch, connect }: JoinEventScreenProps) {
  const classes = useStyles();

  const handleNameChange = (event: ChangeEvent<HTMLInputElement>) => {
    dispatch({ type: 'set-event-name', eventName: event.target.value });
  };

  const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    if (state.participantType === 'speaker') {
      dispatch({ type: 'set-active-screen', activeScreen: ActiveScreen.DeviceSelectionScreen });
    } else {
      connect();
    }
  };

  return (
    <>
      <Typography variant="h5" className={classes.gutterBottom}>
        Join Event
      </Typography>
      <Typography variant="body1">Enter the event name to join</Typography>
      <form onSubmit={handleSubmit}>
        <div className={classes.inputContainer}>
          <div className={classes.textFieldContainer}>
            <InputLabel shrink htmlFor="input-user-name">
              Event name
            </InputLabel>
            <TextField
              id="input-user-name"
              variant="outlined"
              fullWidth
              size="small"
              value={state.eventName}
              onChange={handleNameChange}
            />
          </div>
        </div>
        <Grid container justifyContent="flex-end">
          <Button
            variant="contained"
            type="submit"
            color="primary"
            disabled={!state.eventName}
            className={classes.continueButton}
          >
            {state.participantType === 'speaker' ? 'Continue' : 'Join'}
          </Button>
        </Grid>
      </form>
    </>
  );
}
