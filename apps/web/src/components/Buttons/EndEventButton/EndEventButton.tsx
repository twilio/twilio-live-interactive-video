import React from 'react';
import clsx from 'clsx';
import { createStyles, makeStyles, Theme } from '@material-ui/core/styles';

import { Button, Hidden } from '@material-ui/core';
import ExitToAppIcon from '@material-ui/icons/ExitToApp';

import { useAppState } from '../../../state';
import { deleteStream } from '../../../state/api/api';
import useChatContext from '../../../hooks/useChatContext/useChatContext';
import useSyncContext from '../../../hooks/useSyncContext/useSyncContext';
import useVideoContext from '../../../hooks/useVideoContext/useVideoContext';

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

export default function EndCallButton(props: { className?: string }) {
  const classes = useStyles();
  const { room } = useVideoContext();
  const { disconnect: chatDisconnect } = useChatContext();
  const { disconnect: syncDisconnect } = useSyncContext();
  const { appState, appDispatch } = useAppState();

  async function disconnect() {
    room!.emit('setPreventAutomaticJoinStreamAsViewer');
    room!.disconnect();
    chatDisconnect();
    syncDisconnect();
    appDispatch({ type: 'reset-state' });
    await deleteStream(appState.eventName);
  }

  return (
    <Button onClick={disconnect} className={clsx(classes.button, props.className)} data-cy-disconnect>
      <Hidden smDown>End Event</Hidden>
      <Hidden mdUp>
        <ExitToAppIcon />
      </Hidden>
    </Button>
  );
}
