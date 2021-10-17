import React from 'react';
import { CircularProgress, Grid, Typography } from '@material-ui/core';

export function LoadingScreen() {
  return (
    <Grid container justifyContent="center" alignItems="center" direction="column" style={{ height: '100%' }}>
      <div>
        <CircularProgress variant="indeterminate" />
      </div>
      <div>
        <Typography variant="body2" style={{ fontWeight: 'bold', fontSize: '16px' }}>
          Joining Meeting
        </Typography>
      </div>
    </Grid>
  );
}
