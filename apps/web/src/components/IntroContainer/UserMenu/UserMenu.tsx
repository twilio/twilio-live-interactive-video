import React, { useCallback } from 'react';
import { makeStyles, Link } from '@material-ui/core';
import { useAppState } from '../../../state';
import useVideoContext from '../../../hooks/useVideoContext/useVideoContext';

const useStyles = makeStyles({
  userContainer: {
    position: 'absolute',
    top: 0,
    right: 0,
    margin: '1em',
    display: 'flex',
    alignItems: 'center',
  },
  userButton: {
    color: 'white',
  },
  logoutLink: {
    color: 'white',
    cursor: 'pointer',
    padding: '10px 20px',
  },
});

const UserMenu: React.FC = () => {
  const classes = useStyles();
  const { signOut } = useAppState();
  const { localTracks } = useVideoContext();

  const handleSignOut = useCallback(() => {
    localTracks.forEach(track => track.stop());
    signOut?.();
  }, [localTracks, signOut]);

  return (
    <div className={classes.userContainer}>
      <Link onClick={handleSignOut} className={classes.logoutLink}>
        Logout
      </Link>
    </div>
  );
};

export default UserMenu;
