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

interface ParticpantNameScreenProps {
  state: appStateTypes;
  dispatch: React.Dispatch<appActionTypes>;
}

export default function ParticpantNameScreen({ state, dispatch }: ParticpantNameScreenProps) {
  const classes = useStyles();

  const handleNameChange = (event: ChangeEvent<HTMLInputElement>) => {
    dispatch({ type: 'set-name', name: event.target.value });
  };

  const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    dispatch({ type: 'set-active-screen', activeScreen: ActiveScreen.CreateOrJoinScreen });
  };

  return (
    <>
      <Typography variant="h5" className={classes.gutterBottom}>
        Welcome to Twilio Live Events
      </Typography>
      <Typography variant="body1">What's your name?</Typography>
      <form onSubmit={handleSubmit}>
        <div className={classes.inputContainer}>
          <div className={classes.textFieldContainer}>
            <InputLabel shrink htmlFor="input-user-name">
              Full Name
            </InputLabel>
            <TextField
              id="input-user-name"
              variant="outlined"
              fullWidth
              size="small"
              value={state.name}
              onChange={handleNameChange}
            />
          </div>
        </div>
        <Grid container justifyContent="flex-end">
          <Button
            variant="contained"
            type="submit"
            color="primary"
            disabled={!state.name}
            className={classes.continueButton}
          >
            Continue
          </Button>
        </Grid>
      </form>
    </>
  );
}
