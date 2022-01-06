import React, { useCallback } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import { Typography } from '@material-ui/core';
import { useAppState } from '../../state';
import { useEnqueueSnackbar } from '../../hooks/useSnackbar/useSnackbar';
import { useRaisedHandsMap } from '../../hooks/useRaisedHandsMap/useRaisedHandsMap';
import useVideoContext from '../../hooks/useVideoContext/useVideoContext';
import { useViewersMap } from '../../hooks/useViewersMap/useViewersMap';
import { sendSpeakerInvite } from '../../state/api/api';
import { RaisedHand } from './RaisedHand/RaisedHand';

const useStyles = makeStyles({
  header: {
    fontWeight: 'bold',
    padding: '0.8em 0',
  },
  viewersContainer: {
    padding: '0.4em 1em',
    '& p': {
      padding: '0.5em 0',
    },
    overflow: 'auto',
  },
});

export default function ViewersList() {
  const { appState } = useAppState();
  const { room } = useVideoContext();
  const enqueueSnackbar = useEnqueueSnackbar();
  const raisedHands = useRaisedHandsMap();
  const viewers = useViewersMap();
  const viewersWithoutRaisedHands = viewers.filter(viewer => !raisedHands.includes(viewer));
  const viewerCount = viewersWithoutRaisedHands.length + raisedHands.length;

  const classes = useStyles();

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
    <div className={classes.viewersContainer}>
      <div className={classes.header}>{`Viewers (${viewerCount})`}</div>
      {raisedHands.map(raisedHand => (
        <RaisedHand
          key={raisedHand}
          name={raisedHand}
          handleInvite={handleInvite}
          isHost={appState.participantType === 'host'}
          isLocalViewer={appState.participantName === raisedHand}
        />
      ))}

      {viewersWithoutRaisedHands.map(viewer => (
        <Typography key={viewer} variant="body1">
          {appState.participantName === viewer ? `${viewer} (You)` : viewer}
        </Typography>
      ))}
    </div>
  );
}
