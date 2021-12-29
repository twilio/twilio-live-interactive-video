import React from 'react';
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
}

export function RaisedHand({ name, handleInvite }: RaisedHandProps) {
  const classes = useStyles();

  return (
    <div className={classes.container}>
      <Typography variant="body1">{name} 👋</Typography>
      <Typography variant="body1" className={classes.invite} onClick={() => handleInvite(name)}>
        Invite to speak
      </Typography>
    </div>
  );
}
