import React, { useState, useRef } from 'react';
import { Button, Menu as MenuContainer, MenuItem, Typography } from '@material-ui/core';
import { createStyles, makeStyles, Theme } from '@material-ui/core/styles';
import { joinStreamAsViewer, connectViewerToPlayer } from '../../../state/api/api';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import { useAppState } from '../../../state';
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

export default function LeaveEventButton(props: { buttonClassName?: string }) {
  const classes = useStyles();
  const [menuOpen, setMenuOpen] = useState(false);
  const { room } = useVideoContext();
  const { appState, appDispatch } = useAppState();
  const { connect: playerConnect } = usePlayerContext();
  const { registerUserDocument } = useSyncContext();

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
    appDispatch({ type: 'reset-state' });
  }

  return (
    <>
      <Button onClick={() => setMenuOpen(isOpen => !isOpen)} ref={anchorRef} className={classes.button}>
        Leave Event
        <ExpandMoreIcon />
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
