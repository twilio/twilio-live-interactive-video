import React from 'react';
import clsx from 'clsx';
import { createStyles, makeStyles, Theme } from '@material-ui/core/styles';

import { Button } from '@material-ui/core';

import useVideoContext from '../../../hooks/useVideoContext/useVideoContext';
import { useAppState } from '../../../state';
import { deleteStream } from '../../../state/api/api';

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
  const { appState, appDispatch } = useAppState();

  async function disconnect() {
    await deleteStream(appState.eventName);
    room!.disconnect();
    appDispatch({ type: 'reset-state' });
  }

  return (
    <Button onClick={disconnect} className={clsx(classes.button, props.className)} data-cy-disconnect>
      End Event
    </Button>
  );
}
