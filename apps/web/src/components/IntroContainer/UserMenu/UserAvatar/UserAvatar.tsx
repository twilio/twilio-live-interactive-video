import React from 'react';
import Avatar from '@material-ui/core/Avatar';
import makeStyles from '@material-ui/styles/makeStyles';
import Person from '@material-ui/icons/Person';

const useStyles = makeStyles({
  red: {
    color: 'white',
    backgroundColor: '#F22F46',
  },
});

export default function UserAvatar() {
  const classes = useStyles();

  return (
    <Avatar className={classes.red}>
      <Person />
    </Avatar>
  );
}
