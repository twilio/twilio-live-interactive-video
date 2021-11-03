import React from 'react';
import { createStyles, makeStyles, Theme } from '@material-ui/core/styles';

import Button from '@material-ui/core/Button';
import ScreenShareIcon from '../../../icons/ScreenShareIcon';
import Tooltip from '@material-ui/core/Tooltip';

import usePresentationParticipant from '../../../hooks/usePresentationParticipant/usePresentationParticipant';
import useVideoContext from '../../../hooks/useVideoContext/useVideoContext';

export const SCREEN_SHARE_TEXT = 'Share Screen';
export const STOP_SCREEN_SHARE_TEXT = 'Stop Sharing Screen';
export const SHARE_IN_PROGRESS_TEXT = 'Cannot share screen when another user is sharing';
export const SHARE_NOT_SUPPORTED_TEXT = 'Screen sharing is not supported with this browser';

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    button: {
      '&[disabled]': {
        color: '#bbb',
        '& svg *': {
          fill: '#bbb',
        },
      },
    },
  })
);

export default function TogglePresentationModeButton(props: { disabled?: boolean }) {
  const classes = useStyles();
  const presentationParticipant = usePresentationParticipant();
  const { togglePresentationMode } = useVideoContext();
  const disablePresentationModeButton = Boolean(presentationParticipant);
  const isPresentationModeSupported = navigator.mediaDevices && navigator.mediaDevices.getDisplayMedia;
  const isDisabled = props.disabled || disablePresentationModeButton || !isPresentationModeSupported;

  let tooltipMessage = '';

  if (disablePresentationModeButton) {
    tooltipMessage = SHARE_IN_PROGRESS_TEXT;
  }

  if (!isPresentationModeSupported) {
    tooltipMessage = SHARE_NOT_SUPPORTED_TEXT;
  }

  return (
    <Tooltip
      title={tooltipMessage}
      placement="top"
      PopperProps={{ disablePortal: true }}
      style={{ cursor: isDisabled ? 'not-allowed' : 'pointer' }}
    >
      <span>
        {/* The span element is needed because a disabled button will not emit hover events and we want to display
          a tooltip when screen sharing is disabled */}
        <Button
          className={classes.button}
          onClick={togglePresentationMode}
          disabled={isDisabled}
          startIcon={<ScreenShareIcon />}
          data-cy-share-screen
        >
          {SCREEN_SHARE_TEXT}
        </Button>
      </span>
    </Tooltip>
  );
}
