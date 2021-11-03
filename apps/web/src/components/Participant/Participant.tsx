import React from 'react';
import ParticipantInfo from '../ParticipantInfo/ParticipantInfo';
import ParticipantTracks from '../ParticipantTracks/ParticipantTracks';
import { Participant as IParticipant } from 'twilio-video';

interface ParticipantProps {
  participant: IParticipant;
  videoOnly?: boolean;
  enablePresentationMode?: boolean;
  onClick?: () => void;
  isSelected?: boolean;
  isLocalParticipant?: boolean;
  hideParticipant?: boolean;
}

export default function Participant({
  participant,
  videoOnly,
  enablePresentationMode,
  onClick,
  isSelected,
  isLocalParticipant,
  hideParticipant,
}: ParticipantProps) {
  return (
    <ParticipantInfo
      participant={participant}
      onClick={onClick}
      isSelected={isSelected}
      isLocalParticipant={isLocalParticipant}
      hideParticipant={hideParticipant}
    >
      <ParticipantTracks
        participant={participant}
        videoOnly={videoOnly}
        enablePresentationMode={enablePresentationMode}
        isLocalParticipant={isLocalParticipant}
      />
    </ParticipantInfo>
  );
}
