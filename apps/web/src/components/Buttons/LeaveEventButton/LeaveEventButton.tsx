import React, { useState, useRef } from 'react';
import clsx from 'clsx';
import { Button, Menu as MenuContainer, MenuItem, Typography, Hidden } from '@material-ui/core';
import { createStyles, makeStyles, Theme } from '@material-ui/core/styles';
import { joinStreamAsViewer, connectViewerToPlayer } from '../../../state/api/api';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import ExitToAppIcon from '@material-ui/icons/ExitToApp';
import { useAppState } from '../../../state';
import useChatContext from '../../../hooks/useChatContext/useChatContext';
import usePlayerContext from '../../../hooks/usePlayerContext/usePlayerContext';
import useVideoContext from '../../../hooks/useVideoContext/useVideoContext';
import useSyncContext from '../../../hooks/useSyncContext/useSyncContext';

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    button: {
      background: theme.brand,
      color: 'white',
      '&:hover': {
        background: '#600101',
      },
    },
  })
);

export default function LeaveEventButton() {
  const classes = useStyles();
  const [menuOpen, setMenuOpen] = useState(false);
  const { room } = useVideoContext();
  const { appState, appDispatch } = useAppState();
  const { connect: playerConnect } = usePlayerContext();
  const { registerUserDocument, disconnect: syncDisconnect } = useSyncContext();
  const { disconnect: chatDisconnect } = useChatContext();

  const anchorRef = useRef<HTMLButtonElement>(null);

  async function switchToViewer() {
    setMenuOpen(false);
    const { data } = await joinStreamAsViewer(appState.participantName, appState.eventName);
    await playerConnect(data.token);
    await connectViewerToPlayer(appState.participantName, appState.eventName);
    registerUserDocument(data.sync_object_names.user_document);
    room!.emit('setPreventAutomaticJoinStreamAsViewer');
    room!.disconnect();
  }

  function disconnect() {
    setMenuOpen(false);
    room!.emit('setPreventAutomaticJoinStreamAsViewer');
    room!.disconnect();
    syncDisconnect();
    chatDisconnect();
    appDispatch({ type: 'reset-state' });
  }

  return (
    <>
      <Button
        onClick={() => setMenuOpen(isOpen => !isOpen)}
        ref={anchorRef}
        className={clsx(classes.button, 'MuiButton-mobileBackground')}
      >
        <Hidden smDown>
          Leave Event <ExpandMoreIcon />
        </Hidden>
        <Hidden mdUp>
          <ExitToAppIcon />
        </Hidden>
      </Button>
      <MenuContainer
        open={menuOpen}
        onClose={() => setMenuOpen(false)}
        anchorEl={anchorRef.current}
        anchorOrigin={{
          vertical: 'top',
          horizontal: 'left',
        }}
        transformOrigin={{
          vertical: 'bottom',
          horizontal: 'center',
        }}
      >
        <MenuItem onClick={switchToViewer}>
          <Typography variant="body1">Leave and View Event</Typography>
        </MenuItem>

        <MenuItem onClick={disconnect}>
          <Typography variant="body1">Leave Event</Typography>
        </MenuItem>
      </MenuContainer>
    </>
  );
}
