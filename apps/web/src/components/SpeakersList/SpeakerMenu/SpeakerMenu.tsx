import React, { useState, useRef } from 'react';
import { Button, Menu, MenuItem, MenuList } from '@material-ui/core';
import SpeakerMenuIcon from '../../../icons/SpeakerMenuIcon';
import useVideoContext from '../../../hooks/useVideoContext/useVideoContext';
import { removeSpeaker } from '../../../state/api/api';

export function SpeakerMenu({ speaker }: { speaker: string }) {
  const [menuOpen, setMenuOpen] = useState(false);
  const anchorRef = useRef<HTMLButtonElement>(null);
  const { room } = useVideoContext();

  async function switchToViewer() {
    await removeSpeaker(speaker, room!.name);
  }
  const handleMuteSpeaker = () => {
    const [localDataTrackPublication] = [...room!.localParticipant.dataTracks.values()];
    const messageString = JSON.stringify({ message_type: 'mute', to_participant_identity: speaker });
    const messageBuffer = new TextEncoder().encode(messageString).buffer;
    localDataTrackPublication.track.send(messageBuffer);
  };

  return (
    <>
      <Button onClick={() => setMenuOpen(isOpen => !isOpen)} ref={anchorRef}>
        <SpeakerMenuIcon />
      </Button>
      <Menu
        open={menuOpen}
        onClose={() => setMenuOpen(isOpen => !isOpen)}
        anchorEl={anchorRef.current}
        anchorOrigin={{
          vertical: 'top',
          horizontal: 'left',
        }}
        transformOrigin={{
          vertical: 'top',
          horizontal: 'left',
        }}
      >
        <MenuList dense>
          <MenuItem onClick={handleMuteSpeaker}>Mute Speaker</MenuItem>
          <MenuItem onClick={switchToViewer} style={{ color: 'red' }}>
            Move To Viewers
          </MenuItem>
        </MenuList>
      </Menu>
    </>
  );
}
