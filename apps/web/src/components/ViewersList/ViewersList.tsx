import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import { Typography } from '@material-ui/core';
import { useRaisedHandsMap } from '../../hooks/useRaisedHandsMap/useRaisedHandsMap';
import { useViewersMap } from '../../hooks/useViewersMap/useViewersMap';
import { RaisedHand } from '../ParticipantWindow/RaisedHand/RaisedHand';

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
    maxHeight: '50%',
    overflow: 'auto',
  },
});

interface ViewersListProps {
  handleInvite: (handleInviteIdentity: string) => void;
}

export default function ViewersList({ handleInvite }: ViewersListProps) {
  const raisedHands = useRaisedHandsMap();
  const viewers = useViewersMap();
  const viewersWithoutRaisedHands = viewers.filter(viewer => !raisedHands.includes(viewer));
  const viewerCount = viewersWithoutRaisedHands.length + raisedHands.length;

  const classes = useStyles();

  return (
    <div className={classes.viewersContainer}>
      <div className={classes.header}>{`Viewers (${viewerCount})`}</div>
      {raisedHands.map(raisedHand => (
        <RaisedHand key={raisedHand} name={raisedHand} handleInvite={handleInvite} />
      ))}

      {viewersWithoutRaisedHands.map(viewer => (
        <Typography key={viewer} variant="body1">
          {viewer}
        </Typography>
      ))}
    </div>
  );
}
