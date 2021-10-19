import React from 'react';

import Button from '@material-ui/core/Button';
import { useAppState } from '../../../state';

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
    >
      Participants
    </Button>
  );
}
