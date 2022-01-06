import React from 'react';
import { makeStyles, createStyles, Theme } from '@material-ui/core/styles';
import clsx from 'clsx';
import { useAppState } from '../../state';
import ParticipantWindowHeader from './ParticipantWindowHeader/ParticipantWindowHeader';
import ViewersList from '../ViewersList/ViewersList';
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

  return (
    <aside className={clsx(classes.participantWindowContainer, { [classes.hide]: !appState.isParticipantWindowOpen })}>
      <ParticipantWindowHeader />
      <SpeakersList />
      <ViewersList />
    </aside>
  );
}
