import React from 'react';
import { makeStyles, Typography, Grid, Button, Theme, Hidden } from '@material-ui/core';

import LocalVideoPreview from './LocalVideoPreview/LocalVideoPreview';
import { preJoinActionTypes, ActiveScreen, preJoinStateType } from '../../../state/preJoinState/prejoinReducer';
import SettingsMenu from './SettingsMenu/SettingsMenu';

import ToggleAudioButton from '../../Buttons/ToggleAudioButton/ToggleAudioButton';
import ToggleVideoButton from '../../Buttons/ToggleVideoButton/ToggleVideoButton';
import useVideoContext from '../../../hooks/useVideoContext/useVideoContext';

const useStyles = makeStyles((theme: Theme) => ({
  gutterBottom: {
    marginBottom: '1em',
  },
  marginTop: {
    marginTop: '1em',
  },
  deviceButton: {
    width: '100%',
    border: '2px solid #aaa',
    margin: '1em 0',
  },
  localPreviewContainer: {
    paddingRight: '2em',
    [theme.breakpoints.down('sm')]: {
      padding: '0 2.5em',
    },
  },
  joinButtons: {
    display: 'flex',
    justifyContent: 'space-between',
    '& button': {
      padding: '0.3em 0.7em',
    },
    [theme.breakpoints.down('sm')]: {
      flexDirection: 'column-reverse',
      width: '100%',
      '& button': {
        margin: '0.5em 0',
      },
    },
  },
  mobileButtonBar: {
    [theme.breakpoints.down('sm')]: {
      display: 'flex',
      justifyContent: 'space-between',
      margin: '1.5em 0 1em',
    },
  },
  mobileButton: {
    padding: '0.8em 0',
    margin: 0,
  },
}));

interface DeviceSelectionScreenProps {
  state: preJoinStateType;
  dispatch: React.Dispatch<preJoinActionTypes>;
  connect: () => void;
}

export default function DeviceSelectionScreen({ state, dispatch, connect }: DeviceSelectionScreenProps) {
  const classes = useStyles();
  const { isAcquiringLocalTracks } = useVideoContext();

  return (
    <>
      <Typography variant="h5" className={classes.gutterBottom}>
        Join {state.eventName}
      </Typography>

      <Grid container justifyContent="center">
        <Grid item md={7} sm={12} xs={12}>
          <div className={classes.localPreviewContainer}>
            <LocalVideoPreview identity={state.name} />
          </div>
          <div className={classes.mobileButtonBar}>
            <Hidden mdUp>
              <ToggleAudioButton className={classes.mobileButton} disabled={isAcquiringLocalTracks} />
              <ToggleVideoButton className={classes.mobileButton} disabled={isAcquiringLocalTracks} />
            </Hidden>
            <SettingsMenu mobileButtonClass={classes.mobileButton} />
          </div>
        </Grid>
        <Grid item md={5} sm={12} xs={12}>
          <Grid container direction="column" justifyContent="space-between" style={{ height: '100%' }}>
            <div>
              <Hidden smDown>
                <ToggleAudioButton className={classes.deviceButton} disabled={isAcquiringLocalTracks} />
                <ToggleVideoButton className={classes.deviceButton} disabled={isAcquiringLocalTracks} />
              </Hidden>
            </div>
            <div className={classes.joinButtons}>
              <Button
                variant="outlined"
                color="primary"
                onClick={() =>
                  dispatch({
                    type: 'set-active-screen',
                    activeScreen:
                      state.participantType === 'host'
                        ? ActiveScreen.CreateNewEventScreen
                        : ActiveScreen.JoinEventNameScreen,
                  })
                }
              >
                Go Back
              </Button>
              <Button variant="contained" color="primary" data-cy-join-now onClick={connect}>
                {state.participantType === 'host' ? 'Create Event' : 'Join Event'}
              </Button>
            </div>
          </Grid>
        </Grid>
      </Grid>
    </>
  );
}
