import React from 'react';
import { CircularProgress, Grid, Typography } from '@material-ui/core';
import { appStateTypes } from '../../../state/appState/appReducer';

export function LoadingScreen({ state }: { state: appStateTypes }) {
  return (
    <Grid container justifyContent="center" alignItems="center" direction="column" style={{ height: '100%' }}>
      <div>
        <CircularProgress variant="indeterminate" />
      </div>
      <div>
        <Typography variant="body2" style={{ fontWeight: 'bold', fontSize: '16px' }}>
          {state.participantType === 'host' ? 'Going Live' : 'Joining Live Event'}
        </Typography>
      </div>
    </Grid>
  );
}
