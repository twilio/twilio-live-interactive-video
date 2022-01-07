import React, { useState, useRef } from 'react';
import { Button, Menu, MenuItem, MenuList } from '@material-ui/core';
import SpeakerMenuIcon from '../../../icons/SpeakerMenuIcon';
import useVideoContext from '../../../hooks/useVideoContext/useVideoContext';

export function SpeakerMenu({ speaker }: { speaker: String }) {
  const [menuOpen, setMenuOpen] = useState(false);
  const anchorRef = useRef<HTMLButtonElement>(null);
  const { room } = useVideoContext();

  const handleMuteSpeaker = () => {
    const [localDataTrackPublication] = [...room!.localParticipant.dataTracks.values()];
    const message = JSON.stringify({ message_type: 'mute', to_participant_identity: speaker });
    localDataTrackPublication.track.send(message);
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
          <MenuItem style={{ color: 'red' }}>Move To Viewers</MenuItem>
        </MenuList>
      </Menu>
    </>
  );
}
