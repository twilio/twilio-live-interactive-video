import React from 'react';

import Button from '@material-ui/core/Button';
import { useAppState } from '../../../state';
import ParticipantIcon from '../../../icons/ParticipantIcon';

export default function ToggleParticipantWindowButton() {
  const { appState, appDispatch } = useAppState();

  return (
    <Button
      onClick={() =>
        appDispatch({
          type: 'set-is-participant-window-open',
          isParticipantWindowOpen: !appState.isParticipantWindowOpen,
        })
      }
      startIcon={<ParticipantIcon />}
    >
      Participants
    </Button>
  );
}
