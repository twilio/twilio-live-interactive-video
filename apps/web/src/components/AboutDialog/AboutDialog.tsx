import React, { PropsWithChildren } from 'react';
import Button from '@material-ui/core/Button';
import Dialog from '@material-ui/core/Dialog';
import DialogActions from '@material-ui/core/DialogActions';
import DialogContent from '@material-ui/core/DialogContent';
import DialogContentText from '@material-ui/core/DialogContentText';
import DialogTitle from '@material-ui/core/DialogTitle';
import Divider from '@material-ui/core/Divider';

import { version as appVersion } from '../../../package.json';
import Video from 'twilio-video';
import { useAppState } from '../../state';
import useVideoContext from '../../hooks/useVideoContext/useVideoContext';
import { Link } from '@material-ui/core';

interface AboutDialogProps {
  open: boolean;
  onClose(): void;
}

function AboutDialog({ open, onClose }: PropsWithChildren<AboutDialogProps>) {
  const { roomType } = useAppState();
  const { room } = useVideoContext();

  return (
    <Dialog open={open} onClose={onClose} fullWidth={true} maxWidth="xs">
      <DialogTitle>About</DialogTitle>
      <Divider />
      <DialogContent>
        {room && (
          <DialogContentText>
            Stream Player URL:{' '}
            <Link href={`${window.location.origin}/#/player/${room.name}`} target="_blank" rel="noopener">
              {`${window.location.origin}/#/player/${room.name}`}
            </Link>
          </DialogContentText>
        )}
        <DialogContentText>Browser supported: {String(Video.isSupported)}</DialogContentText>
        <DialogContentText>SDK Version: {Video.version}</DialogContentText>
        <DialogContentText>App Version: {appVersion}</DialogContentText>
        <DialogContentText>Deployed Tag: {process.env.REACT_APP_GIT_TAG || 'N/A'}</DialogContentText>
        <DialogContentText>Deployed Commit Hash: {process.env.REACT_APP_GIT_COMMIT || 'N/A'}</DialogContentText>
        {roomType && <DialogContentText>Room Type: {roomType}</DialogContentText>}
      </DialogContent>
      <Divider />
      <DialogActions>
        <Button onClick={onClose} color="primary" variant="contained" autoFocus>
          OK
        </Button>
      </DialogActions>
    </Dialog>
  );
}

export default AboutDialog;
