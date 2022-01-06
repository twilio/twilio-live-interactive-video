import React, { useState, useRef } from 'react';
import { Button, Menu, MenuItem, MenuList } from '@material-ui/core';
import SpeakerMenuIcon from '../../../icons/SpeakerMenuIcon';

export function SpeakerMenu() {
  const [menuOpen, setMenuOpen] = useState(false);
  const anchorRef = useRef<HTMLButtonElement>(null);

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
          <MenuItem>Return to Viewer</MenuItem>
          <MenuItem>Turn off Speaker's Video</MenuItem>
          <MenuItem>Mute Speaker</MenuItem>
          <MenuItem style={{ color: 'red' }}>Remove User</MenuItem>
        </MenuList>
      </Menu>
    </>
  );
}
