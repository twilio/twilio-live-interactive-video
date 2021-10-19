import React from 'react';
import clsx from 'clsx';
import { makeStyles } from '@material-ui/core/styles';
import { Typography } from '@material-ui/core';

const useStyles = makeStyles({
  container: {
    display: 'flex',
    padding: '0.4em 1em',
    justifyContent: 'space-between',
  },
  invite: {
    fontWeight: 'bold',
    color: '#0263E0',
    cursor: 'pointer',
  },
  hide: {
    visibility: 'hidden',
  },
});

interface RaisedHandProps {
  name: string;
  handleInvite: (handleInviteIdentity: string) => void;
  isHost: boolean;
}

export function RaisedHand({ name, handleInvite, isHost }: RaisedHandProps) {
  const classes = useStyles();

  return (
    <div className={classes.container}>
      <Typography variant="body1">{name}</Typography>
      <Typography
        variant="body1"
        className={clsx(classes.invite, { [classes.hide]: !isHost })}
        onClick={() => handleInvite(name)}
      >
        Invite to speak
      </Typography>
    </div>
  );
}
