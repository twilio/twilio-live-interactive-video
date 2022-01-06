import React from 'react';
import { makeStyles, createStyles } from '@material-ui/core/styles';
import CloseIcon from '../../../icons/CloseIcon';
import { useAppState } from '../../../state';

const useStyles = makeStyles(() =>
  createStyles({
    container: {
      height: '56px',
      background: '#F4F4F6',
      borderBottom: '1px solid #E4E7E9',
      display: 'flex',
      flexShrink: 0,
      justifyContent: 'space-between',
      alignItems: 'center',
      padding: '0 1em',
      marginBottom: '0.6em',
    },
    text: {
      fontWeight: 'bold',
    },
    closeParticipantWindow: {
      cursor: 'pointer',
      display: 'flex',
      background: 'transparent',
      border: '0',
      padding: '0.4em',
    },
  })
);

export default function ParticipantWindowHeader() {
  const classes = useStyles();
  const { appDispatch } = useAppState();

  return (
    <div className={classes.container}>
      <div className={classes.text}>Participants</div>
      <button
        className={classes.closeParticipantWindow}
        onClick={() => appDispatch({ type: 'set-is-participant-window-open', isParticipantWindowOpen: false })}
      >
        <CloseIcon />
      </button>
    </div>
  );
}
