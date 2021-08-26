import React from 'react';
import { createStyles, makeStyles, Theme } from '@material-ui/core/styles';
import { Typography, Grid, Hidden, Button } from '@material-ui/core';
import { useHistory } from 'react-router-dom';

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    container: {
      backgroundColor: theme.palette.background.default,
      bottom: 0,
      left: 0,
      right: 0,
      height: `${theme.footerHeight}px`,
      position: 'fixed',
      display: 'flex',
      padding: '0 1.43em',
      zIndex: 10,
      [theme.breakpoints.down('sm')]: {
        height: `${theme.mobileFooterHeight}px`,
        padding: 0,
      },
    },
    button: {
      background: theme.brand,
      color: 'white',
      '&:hover': {
        background: '#600101',
      },
    },
  })
);

export default function PlayerMenuBar({ roomName }: { roomName?: string }) {
  const classes = useStyles();
  const history = useHistory();

  return (
    <footer className={classes.container}>
      <Grid container justifyContent="space-around" alignItems="center">
        <Hidden smDown>
          <Grid style={{ flex: 1 }}>
            <Typography variant="body1">{roomName}</Typography>
          </Grid>
        </Hidden>
        <Hidden smDown>
          <Grid style={{ flex: 1 }}>
            <Grid container justifyContent="flex-end">
              <Button onClick={() => history.replace('/')} className={classes.button}>
                Leave Stream
              </Button>
            </Grid>
          </Grid>
        </Hidden>
      </Grid>
    </footer>
  );
}
