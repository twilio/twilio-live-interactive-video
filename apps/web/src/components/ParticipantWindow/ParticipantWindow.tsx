import React, { useCallback } from 'react';
import { makeStyles, createStyles, Theme } from '@material-ui/core/styles';
import clsx from 'clsx';
import { Typography } from '@material-ui/core';
import { useAppState } from '../../state';
import ParticipantWindowHeader from './ParticipantWindowHeader/ParticipantWindowHeader';
import { useRaisedHandsMap } from '../../hooks/useRaisedHandsMap/useRaisedHandsMap';
import { useViewersMap } from '../../hooks/useViewersMap/useViewersMap';
import { RaisedHand } from './RaisedHand/RaisedHand';
import useVideoContext from '../../hooks/useVideoContext/useVideoContext';
import { sendSpeakerInvite } from '../../state/api/api';
import { useEnqueueSnackbar } from '../../hooks/useSnackbar/useSnackbar';

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
    header: {
      fontWeight: 'bold',
      padding: '0 1em',
    },
  })
);

export default function ParticipantWindow() {
  const classes = useStyles();
  const { appState } = useAppState();
  const raisedHands = useRaisedHandsMap();
  const viewers = useViewersMap();
  const { room } = useVideoContext();
  const enqueueSnackbar = useEnqueueSnackbar();

  const handleInvite = useCallback(
    (raisedHand: string) => {
      sendSpeakerInvite(raisedHand, room!.sid);
      enqueueSnackbar({
        headline: 'Invite Sent',
        message: `You invited ${raisedHand} to be a speaker. They will now be able to share audio and video.`,
        variant: 'info',
      });
    },
    [room, enqueueSnackbar]
  );

  const viewersWithoutRaisedHands = viewers.filter(viewer => !raisedHands.includes(viewer));

  return (
    <aside className={clsx(classes.participantWindowContainer, { [classes.hide]: !appState.isParticipantWindowOpen })}>
      <ParticipantWindowHeader />
      <div className={classes.header}>{`Viewers (${viewersWithoutRaisedHands.length + raisedHands.length})`}</div>

      {raisedHands.map(raisedHand => (
        <RaisedHand key={raisedHand} name={raisedHand} handleInvite={handleInvite} />
      ))}

      <div style={{ padding: '0.4em 1em' }}>
        {viewersWithoutRaisedHands.map(viewer => (
          <>
            <Typography variant="body1">{viewer}</Typography>
          </>
        ))}
      </div>
    </aside>
  );
}
