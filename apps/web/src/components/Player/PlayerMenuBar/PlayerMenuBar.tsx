import React, { useCallback, useRef, useState } from 'react';
import { createStyles, makeStyles, Theme } from '@material-ui/core/styles';
import { Typography, Grid, Button } from '@material-ui/core';
import { useAppState } from '../../../state';
import { raiseHand } from '../../../state/api/api';
import { useEnqueueSnackbar } from '../../../hooks/useSnackbar/useSnackbar';
import LowerHandIcon from '../../../icons/LowerHandIcon';
import RaiseHandIcon from '../../../icons/RaiseHandIcon';

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    container: {
      backgroundColor: theme.palette.background.default,
      bottom: 0,
      left: 0,
      right: 0,
      height: `${theme.footerHeight}px`,
      position: 'fixed',
      display: 'flex',
      padding: '0 1.43em',
      zIndex: 10,
      [theme.breakpoints.down('sm')]: {
        height: `${theme.mobileFooterHeight}px`,
        padding: 0,
      },
    },
    button: {
      background: theme.brand,
      color: 'white',
      '&:hover': {
        background: '#600101',
      },
    },
  })
);

export default function PlayerMenuBar({ roomName, disconnect }: { roomName?: string; disconnect: () => void }) {
  const classes = useStyles();
  const { appState, appDispatch } = useAppState();
  const [isHandRaised, setIsHandRaised] = useState(false);
  const lastClickTimeRef = useRef(0);
  const enqueueSnackbar = useEnqueueSnackbar();

  const handleRaiseHand = useCallback(() => {
    if (Date.now() - lastClickTimeRef.current > 500) {
      lastClickTimeRef.current = Date.now();
      raiseHand(appState.participantName, appState.eventName, !isHandRaised).then(() => {
        if (!isHandRaised) {
          enqueueSnackbar({
            headline: '',
            message: "Your request was sent! If the host accepts, you'll be able to share audio and video",
            variant: 'info',
          });
        }
        setIsHandRaised(!isHandRaised);
      });
    }
  }, [isHandRaised, appState.participantName, appState.eventName, enqueueSnackbar]);

  return (
    <footer className={classes.container}>
      <Grid container justifyContent="space-around" alignItems="center">
        <Grid style={{ flex: 1 }}>
          <Typography variant="body1">{roomName}</Typography>
        </Grid>
        <Grid item>
          <Grid container justifyContent="center">
            <Button onClick={handleRaiseHand} startIcon={isHandRaised ? <LowerHandIcon /> : <RaiseHandIcon />}>
              {isHandRaised ? 'Lower Hand' : 'Raise Hand'}
            </Button>
          </Grid>
        </Grid>

        <Grid style={{ flex: 1 }}>
          <Grid container justifyContent="flex-end">
            <Button
              onClick={() => {
                disconnect();
                appDispatch({ type: 'reset-state' });
              }}
              className={classes.button}
            >
              Leave Stream
            </Button>
          </Grid>
        </Grid>
      </Grid>
    </footer>
  );
}
