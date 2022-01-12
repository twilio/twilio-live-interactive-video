import React from 'react';
import clsx from 'clsx';
import { Typography, makeStyles, Button, Theme } from '@material-ui/core';
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
    width: '100%',
    flexDirection: 'column',
    height: '13em',
    justifyContent: 'space-between',
    marginTop: '0.5em',
  },
  paper: {
    height: '84px',
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
      padding: '0.2em 0',
    },
  },
  innerPaperContainer: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  disabledPaper: {
    pointerEvents: 'none',
    opacity: 0.2,
  },
  bodyTypography: {
    color: '#606B85',
    fontWeight: 'bold',
    marginBottom: '0.2em',
  },
  typographyContainer: {
    textAlign: 'left',
    margin: '0 auto 0 0.5em',
    [theme.breakpoints.down('sm')]: {
      marginLeft: '0.5em',
    },
  },
  leftIcon: {
    margin: '0 0.5em 0',
  },
  rightArrowIcon: {
    margin: '0.5em 0.5em 0 0',
  },
  backButton: {
    marginTop: '1.5em',
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
        <button
          autoFocus
          onClick={() => dispatch({ type: 'set-participant-type', participantType: 'speaker' })}
          className={clsx(classes.paper, { [classes.disabledPaper]: !state.participantName })}
        >
          <div className={classes.innerPaperContainer}>
            <div className={classes.leftIcon}>
              <SpeakerIcon />
            </div>
            <div className={classes.typographyContainer}>
              <Typography variant="body2" className={classes.bodyTypography}>
                Join as speaker
              </Typography>
              <Typography variant="caption" style={{ color: '#606B85' }}>
                Your audio/video will be shared by default.
              </Typography>
            </div>
            <div className={classes.rightArrowIcon}>
              <RightArrowIcon />
            </div>
          </div>
        </button>

        <button
          onClick={() => dispatch({ type: 'set-participant-type', participantType: 'viewer' })}
          className={clsx(classes.paper, { [classes.disabledPaper]: !state.participantName })}
        >
          <div className={classes.innerPaperContainer}>
            <div className={classes.leftIcon}>
              <ViewerIcon />
            </div>
            <div className={classes.typographyContainer}>
              <Typography variant="body2" className={classes.bodyTypography}>
                Join as viewer
              </Typography>
              <Typography variant="caption" style={{ color: '#606B85' }}>
                You’ll have to raise your hand to speak or share video. Your audio/video will not be shared by default.
              </Typography>
            </div>
            <div className={classes.rightArrowIcon}>
              <RightArrowIcon />
            </div>
          </div>
        </button>
      </div>

      <div>
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
      </div>
    </>
  );
}
