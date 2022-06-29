import React, { ChangeEvent, FormEvent } from 'react';
import {
  Typography,
  makeStyles,
  TextField,
  Grid,
  Button,
  InputLabel,
  Theme,
  FormControlLabel,
  Checkbox,
} from '@material-ui/core';
import { appActionTypes, ActiveScreen, appStateTypes } from '../../../state/appState/appReducer';

const useStyles = makeStyles((theme: Theme) => ({
  gutterBottom: {
    marginBottom: '1.5em',
    fontWeight: 'bold',
  },
  inputContainer: {
    justifyContent: 'space-between',
    margin: '1.5em 0 1.3em',
    '& div:not(:last-child)': {
      marginRight: '1em',
    },
    [theme.breakpoints.down('sm')]: {
      margin: '1.5em 0 1.2em',
    },
  },
  textFieldContainer: {
    width: '100%',
    marginBottom: '1em',
  },
  continueButton: {
    [theme.breakpoints.down('sm')]: {
      width: '100%',
    },
  },
}));

interface CreateNewEventScreenProps {
  state: appStateTypes;
  dispatch: React.Dispatch<appActionTypes>;
}

export default function CreateNewEventScreen({ state, dispatch }: CreateNewEventScreenProps) {
  const classes = useStyles();

  const handleNameChange = (event: ChangeEvent<HTMLInputElement>) => {
    dispatch({ type: 'set-event-name', eventName: event.target.value });
  };

  const handleRecordChange = (event: ChangeEvent<HTMLInputElement>) => {
    dispatch({ type: 'set-record-stream', recordStream: event.target.checked });
  };

  const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    dispatch({ type: 'set-active-screen', activeScreen: ActiveScreen.DeviceSelectionScreen });
  };

  return (
    <div>
      <Typography variant="h5" className={classes.gutterBottom}>
        Create new event
      </Typography>
      <Typography variant="body2" className={classes.gutterBottom} style={{ color: '#606B85' }}>
        Tip: give your event a name that’s related to the topic you’ll be talking about.
      </Typography>
      <form onSubmit={handleSubmit}>
        <div className={classes.inputContainer}>
          <div className={classes.textFieldContainer}>
            <InputLabel shrink htmlFor="input-user-name" style={{ fontWeight: 'bold' }}>
              Event name
            </InputLabel>
            <TextField
              id="input-user-name"
              autoFocus
              variant="outlined"
              fullWidth
              size="small"
              value={state.eventName}
              onChange={handleNameChange}
            />
          </div>
          <div>
            <FormControlLabel
              control={
                <Checkbox
                  checked={state.recordStream}
                  onChange={handleRecordChange}
                  name="record-stream"
                  color="primary"
                />
              }
              label="Record Stream"
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
            Continue
          </Button>
        </Grid>
      </form>
    </div>
  );
}
