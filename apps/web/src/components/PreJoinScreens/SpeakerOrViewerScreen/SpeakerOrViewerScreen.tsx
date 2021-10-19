import React from 'react';
import clsx from 'clsx';
import { Typography, makeStyles, Button, Theme, Paper } from '@material-ui/core';
import { appActionTypes, ActiveScreen, appStateTypes } from '../../../state/appState/appReducer';
import BackArrowIcon from '../../../icons/BackArrowIcon';
import SpeakerIcon from '../../../icons/SpeakerIcon';
import ViewerIcon from '../../../icons/ViewerIcon';
import RightArrowIcon from '../../../icons/RightArrowIcon';

const useStyles = makeStyles((theme: Theme) => ({
  gutterBottom: {
    marginBottom: '0.5em',
    fontWeight: 'bold',
  },
  paperContainer: {
    display: 'flex',
    flexDirection: 'column',
    height: '65%',
    justifyContent: 'space-around',
  },
  paper: {
    width: '465px',
    height: '80px',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    cursor: 'pointer',
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
    margin: '0 1em 0',
  },
  rightArrowIcon: {
    margin: '0.5em 1em 0 0',
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
  backButton: {
    marginTop: '2em',
    fontWeight: 'bold',
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
      <Typography variant="caption" className={classes.gutterBottom} style={{ color: '#606B85' }}>
        Do you plan on chatting up the room or are you more of the quiet, mysterious audience type?
      </Typography>

      <div className={classes.paperContainer}>
        <div>
          <Paper
            onClick={() => dispatch({ type: 'set-participant-type', participantType: 'speaker' })}
            className={clsx(classes.paper, { [classes.disabledPaper]: !state.participantName })}
            elevation={1}
            style={{ margin: '0.3em 0' }}
          >
            <div className={classes.innerPaperContainer}>
              <div className={classes.leftIcon}>
                <SpeakerIcon />
              </div>
              <div>
                <Typography variant="body2" className={classes.bodyTypography}>
                  Join as speaker
                </Typography>
                <Typography variant="caption" style={{ color: '#606B85' }}>
                  Your audio/video will be shared by default.
                </Typography>
              </div>
            </div>
            <div className={classes.rightArrowIcon}>
              <RightArrowIcon />
            </div>
          </Paper>
        </div>

        <div>
          <Paper
            onClick={() => dispatch({ type: 'set-participant-type', participantType: 'viewer' })}
            elevation={1}
            color="primary"
            className={clsx(classes.paper, { [classes.disabledPaper]: !state.participantName })}
          >
            <div className={classes.innerPaperContainer}>
              <div className={classes.leftIcon}>
                <ViewerIcon />
              </div>
              <div>
                <Typography variant="body2" className={classes.bodyTypography}>
                  Join as viewer
                </Typography>
                <Typography variant="caption" style={{ color: '#606B85' }}>
                  You’ll have to raise your hand to speak or share video.
                  <div>Your audio/video will not be shared by default.</div>
                </Typography>
              </div>
            </div>
            <div className={classes.rightArrowIcon}>
              <RightArrowIcon />
            </div>
          </Paper>
        </div>
      </div>

      <Button
        startIcon={<BackArrowIcon />}
        onClick={() => dispatch({ type: 'set-active-screen', activeScreen: ActiveScreen.CreateOrJoinScreen })}
        variant="outlined"
        disabled={!state.participantName}
        className={classes.backButton}
        size="small"
      >
        Go back
      </Button>
    </>
  );
}
