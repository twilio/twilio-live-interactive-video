import React from 'react';
import clsx from 'clsx';
import { Typography, makeStyles, Button, Theme } from '@material-ui/core';
import { appActionTypes, ActiveScreen, appStateTypes } from '../../../state/appState/appReducer';
import BackArrowIcon from '../../../icons/BackArrowIcon';
import CreateEventIcon from '../../../icons/CreateEventIcon';
import JoinEventIcon from '../../../icons/JoinEventIcon';
import RightArrowIcon from '../../../icons/RightArrowIcon';

const useStyles = makeStyles((theme: Theme) => ({
  gutterBottom: {
    marginBottom: '1em',
    fontWeight: 'bold',
  },
  paperContainer: {
    display: 'flex',
    flexDirection: 'column',
    height: '70%',
    justifyContent: 'space-evenly',
  },
  paper: {
    width: '100%',
    height: '75px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: '#fff',
    borderColor: 'transparent',
    borderRadius: '4px',
    boxShadow: '0px 3px 3px -2px rgb(0 0 0 / 20%), 0px 3px 4px 0px rgb(0 0 0 / 14%), 0px 1px 8px 0px rgb(0 0 0 / 12%)',
    cursor: 'pointer',
    transition: 'all 0.2s linear',
    '&:hover': {
      backgroundColor: '#EFEFEF',
    },
    [theme.breakpoints.down('sm')]: {
      margin: '0.8em 0',
    },
  },
  innerPaperContainer: {
    display: 'flex',
    alignItems: 'center',
  },
  disabledPaper: {
    pointerEvents: 'none',
    opacity: 0.2,
  },
  bodyTypography: {
    color: '#606B85',
    fontWeight: 'bold',
  },
  leftIcon: {
    margin: '0 0.7em 0 0.5em',
  },
  rightArrowIcon: {
    margin: '0.5em 0.5em 0 0',
  },
  backButton: {
    marginTop: '0.8em',
    fontWeight: 'bold',
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
      <Typography variant="h5" className={classes.gutterBottom}>
        Create or join?
      </Typography>
      <Typography variant="body2" style={{ color: '#606B85', fontWeight: 'bold' }}>
        Create your own event or join one that's already happening.
      </Typography>

      <div className={classes.paperContainer}>
        <button
          autoFocus
          onClick={() => dispatch({ type: 'set-participant-type', participantType: 'host' })}
          className={clsx(classes.paper, { [classes.disabledPaper]: !state.participantName })}
        >
          <div className={classes.innerPaperContainer}>
            <div className={classes.leftIcon}>
              <CreateEventIcon />
            </div>
            <Typography variant="body2" className={classes.bodyTypography}>
              Create a new event
            </Typography>
          </div>
          <div className={classes.rightArrowIcon}>
            <RightArrowIcon />
          </div>
        </button>

        <button
          onClick={() => dispatch({ type: 'set-participant-type', participantType: null })}
          className={clsx(classes.paper, { [classes.disabledPaper]: !state.participantName })}
        >
          <div className={classes.innerPaperContainer}>
            <div className={classes.leftIcon}>
              <JoinEventIcon />
            </div>
            <Typography variant="body2" className={classes.bodyTypography}>
              Join an event
            </Typography>
          </div>
          <div className={classes.rightArrowIcon}>
            <RightArrowIcon />
          </div>
        </button>
      </div>
      <div>
        <Button
          startIcon={<BackArrowIcon />}
          onClick={() => dispatch({ type: 'set-active-screen', activeScreen: ActiveScreen.ParticipantNameScreen })}
          variant="outlined"
          disabled={!state.participantName}
          className={classes.backButton}
          size="small"
        >
          Go back
        </Button>
      </div>
    </>
  );
}
