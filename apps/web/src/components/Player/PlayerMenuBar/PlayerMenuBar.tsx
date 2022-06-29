import React, { useCallback, useRef, useState } from 'react';
import clsx from 'clsx';
import { createStyles, makeStyles, Theme } from '@material-ui/core/styles';
import { Typography, Grid, Button, Hidden } from '@material-ui/core';
import ExitToAppIcon from '@material-ui/icons/ExitToApp';
import { useAppState } from '../../../state';
import { raiseHand } from '../../../state/api/api';
import { useEnqueueSnackbar } from '../../../hooks/useSnackbar/useSnackbar';
import LowerHandIcon from '../../../icons/LowerHandIcon';
import RaiseHandIcon from '../../../icons/RaiseHandIcon';
import ParticipantIcon from '../../../icons/ParticipantIcon';
import ChatIcon from '../../../icons/ChatIcon';
import useChatContext from '../../../hooks/useChatContext/useChatContext';
import useSyncContext from '../../../hooks/useSyncContext/useSyncContext';

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
        '& .MuiButton-startIcon': {
          margin: 0,
        },
      },
    },
    mobileBackground: {
      [theme.breakpoints.down('sm')]: {
        marginRight: '1em',
        padding: '12px',
        borderRadius: '50%',
        minWidth: 0,
        height: '40px',
        width: '40px',
        '&:not(:last-child)': {
          background: '#E1E3EA',
        },
      },
    },
    mobileRoomLabel: {
      display: 'flex',
      alignItems: 'center',
      marginLeft: '0.5em',
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
  const { setIsChatWindowOpen, isChatWindowOpen } = useChatContext();
  const [isHandRaised, setIsHandRaised] = useState(false);
  const lastClickTimeRef = useRef(0);
  const enqueueSnackbar = useEnqueueSnackbar();
  const { disconnect: chatDisconnect } = useChatContext();
  const { disconnect: syncDisconnect } = useSyncContext();

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

  const toggleParticipantWindow = () => {
    setIsChatWindowOpen(false);
    appDispatch({
      type: 'set-is-participant-window-open',
      isParticipantWindowOpen: !appState.isParticipantWindowOpen,
    });
  };

  const toggleChatWindow = () => {
    setIsChatWindowOpen(!isChatWindowOpen);
    appDispatch({
      type: 'set-is-participant-window-open',
      isParticipantWindowOpen: false,
    });
  };

  const disconnectFromEvent = () => {
    disconnect();
    appDispatch({ type: 'reset-state' });
    chatDisconnect();
    syncDisconnect();
  };

  return (
    <footer className={classes.container}>
      <Hidden mdUp>
        <Typography variant="body1" className={classes.mobileRoomLabel}>
          {roomName}
        </Typography>
      </Hidden>
      <Grid container justifyContent="center" alignItems="center">
        <Hidden smDown>
          <Grid style={{ flex: 1 }}>
            <Typography variant="body1">{roomName}</Typography>
          </Grid>
        </Hidden>
        <Grid item>
          <Grid container>
            <Button
              onClick={handleRaiseHand}
              className={classes.mobileBackground}
              startIcon={isHandRaised ? <LowerHandIcon /> : <RaiseHandIcon />}
            >
              <Hidden smDown>{isHandRaised ? 'Lower Hand' : 'Raise Hand'}</Hidden>
            </Button>
            <Button
              onClick={() => toggleParticipantWindow()}
              className={classes.mobileBackground}
              startIcon={<ParticipantIcon />}
            >
              <Hidden smDown>Participants</Hidden>
            </Button>
            {appState.isChatEnabled && (
              <Button onClick={() => toggleChatWindow()} className={classes.mobileBackground} startIcon={<ChatIcon />}>
                <Hidden smDown>Chat</Hidden>
              </Button>
            )}

            <Hidden mdUp>
              <Button onClick={disconnectFromEvent} className={clsx(classes.button, classes.mobileBackground)}>
                <ExitToAppIcon />
              </Button>
            </Hidden>
          </Grid>
        </Grid>

        {/* Move 'Leave Stream' button all the way to the right if on Desktop */}
        <Hidden smDown>
          <Grid style={{ flex: 1 }}>
            <Grid container justifyContent="flex-end">
              <Button onClick={disconnectFromEvent} className={classes.button}>
                Leave Stream
              </Button>
            </Grid>
          </Grid>
        </Hidden>
      </Grid>
    </footer>
  );
}
