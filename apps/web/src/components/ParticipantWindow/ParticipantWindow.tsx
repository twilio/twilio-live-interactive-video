import React, { useCallback } from 'react';
import { makeStyles, createStyles, Theme } from '@material-ui/core/styles';
import clsx from 'clsx';
import { useAppState } from '../../state';
import ParticipantWindowHeader from './ParticipantWindowHeader/ParticipantWindowHeader';
import { useRaisedHandsMap } from '../../hooks/useRaisedHandsMap/useRaisedHandsMap';
import { RaisedHand } from './RaisedHand/RaisedHand';
import useVideoContext from '../../hooks/useVideoContext/useVideoContext';
import { sendSpeakerInvite } from '../../state/api/api';

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    participantWindowContainer: {
      background: '#FFFFFF',
      zIndex: 9,
      display: 'flex',
      flexDirection: 'column',
      borderLeft: '1px solid #E4E7E9',
      [theme.breakpoints.down('sm')]: {
        position: 'fixed',
        top: 0,
        left: 0,
        bottom: 0,
        right: 0,
        zIndex: 100,
      },
    },
    hide: {
      display: 'none',
    },
  })
);

export default function ParticipantWindow() {
  const classes = useStyles();
  const { appState } = useAppState();
  const raisedHands = useRaisedHandsMap();
  const { room } = useVideoContext();

  console.log('hands!', raisedHands);

  const handleInvite = useCallback(
    (raisedHand: string) => {
      sendSpeakerInvite(raisedHand, room!.sid);
    },
    [room]
  );

  return (
    <aside className={clsx(classes.participantWindowContainer, { [classes.hide]: !appState.isParticipantWindowOpen })}>
      <ParticipantWindowHeader />
      {raisedHands.map(raisedHand => (
        <RaisedHand
          key={raisedHand}
          name={raisedHand}
          handleInvite={handleInvite}
          isHost={appState.participantType === 'host'}
        />
      ))}
    </aside>
  );
}
