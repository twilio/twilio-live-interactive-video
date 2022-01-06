import React, { useCallback } from 'react';
import { makeStyles, createStyles, Theme } from '@material-ui/core/styles';
import clsx from 'clsx';
import { useAppState } from '../../state';
import ParticipantWindowHeader from './ParticipantWindowHeader/ParticipantWindowHeader';
import ViewersList from '../ViewersList/ViewersList';
import useVideoContext from '../../hooks/useVideoContext/useVideoContext';
import { sendSpeakerInvite } from '../../state/api/api';
import { useEnqueueSnackbar } from '../../hooks/useSnackbar/useSnackbar';
import SpeakersList from '../SpeakersList/SpeakersList';

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

  return (
    <aside className={clsx(classes.participantWindowContainer, { [classes.hide]: !appState.isParticipantWindowOpen })}>
      <ParticipantWindowHeader />
      <SpeakersList />
      <ViewersList handleInvite={handleInvite} />
    </aside>
  );
}
