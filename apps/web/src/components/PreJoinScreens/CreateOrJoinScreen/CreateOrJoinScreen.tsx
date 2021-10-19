import React from 'react';
import { Typography, makeStyles, Grid, Button, Theme, Paper } from '@material-ui/core';
import { appActionTypes, ActiveScreen, appStateTypes } from '../../../state/appState/appReducer';
import CreateEventIcon from '../../../icons/CreateEventIcon';
import RightArrowIcon from '../../../icons/RightArrowIcon';

const useStyles = makeStyles((theme: Theme) => ({
  gutterBottom: {
    marginBottom: '1em',
    fontWeight: 'bold',
  },
  actionsContainer: {
    display: 'flex',
    flexDirection: 'column',
  },
  paper: {
    width: '464px',
    height: '72px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
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
  state: appStateTypes;
  dispatch: React.Dispatch<appActionTypes>;
}

export default function CreateOrJoinScreen({ state, dispatch }: CreateOrJoinScreenProps) {
  const classes = useStyles();

  return (
    <>
      <Typography variant="h4" className={classes.gutterBottom}>
        Create or Join?
      </Typography>
      <Typography variant="body2" className={classes.gutterBottom} style={{ color: '#606B85' }}>
        Create your own event or join one that's already happening.
      </Typography>

      <Grid container justifyContent="space-between">
        <Grid item xs={12} style={{ marginTop: '10px' }}>
          <Paper
            variant="outlined"
            onClick={() => dispatch({ type: 'set-participant-type', participantType: 'host' })}
            // disabled={!state.participantName}
            className={classes.paper}
          >
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', width: '50%' }}>
              <CreateEventIcon />
              <Typography variant="body2" style={{ color: '#606B85', fontWeight: 'bold' }}>
                Create a New Event
              </Typography>
            </div>
            <div style={{ margin: '0.5em 1em 0 0' }}>
              <RightArrowIcon />
            </div>
          </Paper>
        </Grid>
        <Grid item xs={12}>
          <Button
            onClick={() => dispatch({ type: 'set-participant-type', participantType: null })}
            variant="contained"
            color="primary"
            disabled={!state.participantName}
            className={classes.continueButton}
          >
            Join an Event
          </Button>
        </Grid>
        <Grid item xs={12}>
          <Button
            onClick={() => dispatch({ type: 'set-active-screen', activeScreen: ActiveScreen.ParticipantNameScreen })}
            variant="contained"
            color="primary"
            disabled={!state.participantName}
            className={classes.continueButton}
          >
            Go Back
          </Button>
        </Grid>
      </Grid>
    </>
  );
}
