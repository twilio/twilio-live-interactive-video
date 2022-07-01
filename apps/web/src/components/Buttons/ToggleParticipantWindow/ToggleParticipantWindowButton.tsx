import React, { useEffect, useState } from 'react';

import Button from '@material-ui/core/Button';
import clsx from 'clsx';
import { makeStyles, Hidden } from '@material-ui/core';
import ParticipantIcon from '../../../icons/ParticipantIcon';
import { useAppState } from '../../../state';
import useVideoContext from '../../../hooks/useVideoContext/useVideoContext';
import useChatContext from '../../../hooks/useChatContext/useChatContext';
import { useRaisedHandsMap } from '../../../hooks/useRaisedHandsMap/useRaisedHandsMap';
import useSyncContext from '../../../hooks/useSyncContext/useSyncContext';

export const ANIMATION_DURATION = 700;

const useStyles = makeStyles({
  iconContainer: {
    position: 'relative',
    display: 'flex',
  },
  circle: {
    width: '10px',
    height: '10px',
    backgroundColor: '#D61F1F',
    borderRadius: '50%',
    position: 'absolute',
    top: '-3px',
    left: '13px',
    opacity: 0,
    transition: `opacity ${ANIMATION_DURATION * 0.5}ms ease-in`,
  },
  hasRaisedHands: {
    opacity: 1,
  },
  ring: {
    border: '3px solid #D61F1F',
    borderRadius: '30px',
    height: '14px',
    width: '14px',
    position: 'absolute',
    left: '11px',
    top: '-5px',
    opacity: 0,
  },
  animateRing: {
    animation: `$expand ${ANIMATION_DURATION}ms ease-out`,
    animationIterationCount: 1,
  },
  '@keyframes expand': {
    '0%': {
      transform: 'scale(0.1, 0.1)',
      opacity: 0,
    },
    '50%': {
      opacity: 1,
    },
    '100%': {
      transform: 'scale(1.4, 1.4)',
      opacity: 0,
    },
  },
});

export default function ToggleParticipantWindowButton() {
  const classes = useStyles();
  const { appState, appDispatch } = useAppState();
  const [shouldAnimate, setShouldAnimate] = useState(false);
  const { setIsBackgroundSelectionOpen } = useVideoContext();
  const { setIsChatWindowOpen } = useChatContext();
  const raisedHands = useRaisedHandsMap();
  const { raisedHandsMap } = useSyncContext();

  const toggleParticipantWindow = () => {
    setIsBackgroundSelectionOpen(false);
    setIsChatWindowOpen(false);
    appDispatch({
      type: 'set-is-participant-window-open',
      isParticipantWindowOpen: !appState.isParticipantWindowOpen,
    });
  };

  useEffect(() => {
    if (shouldAnimate) {
      setTimeout(() => setShouldAnimate(false), ANIMATION_DURATION);
    }
  }, [shouldAnimate]);

  useEffect(() => {
    if (raisedHandsMap && !appState.isParticipantWindowOpen) {
      const handleNewItem = () => setShouldAnimate(true);
      raisedHandsMap.on('itemAdded', handleNewItem);
      return () => {
        raisedHandsMap.off('itemAdded', handleNewItem);
      };
    }
  }, [raisedHandsMap, appState.isParticipantWindowOpen]);

  return (
    <Button
      className="MuiButton-mobileBackground"
      onClick={toggleParticipantWindow}
      startIcon={
        <div className={classes.iconContainer}>
          <ParticipantIcon />
          <div className={clsx(classes.ring, { [classes.animateRing]: shouldAnimate })} />
          <div
            className={clsx(classes.circle, {
              [classes.hasRaisedHands]: raisedHands.length > 0,
            })}
          />
        </div>
      }
    >
      <Hidden smDown>Participants</Hidden>
    </Button>
  );
}
