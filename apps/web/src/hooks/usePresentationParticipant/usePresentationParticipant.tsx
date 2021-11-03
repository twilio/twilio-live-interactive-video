import { useEffect, useState } from 'react';
import useVideoContext from '../useVideoContext/useVideoContext';

import { Participant, TrackPublication } from 'twilio-video';

/*
  Returns the participant that is presenting content (if any). This hook assumes that only one participant
  can present content at a time.
*/
export default function usePresentationParticipant() {
  const { room } = useVideoContext();
  const [presentationParticipant, setPresentationParticipant] = useState<Participant>();

  useEffect(() => {
    if (room) {
      const updatePresentationParticipant = () => {
        setPresentationParticipant(
          Array.from<Participant>(room.participants.values())
            // the presentation participant could be the localParticipant
            .concat(room.localParticipant)
            .find((participant: Participant) =>
              Array.from<TrackPublication>(participant.tracks.values()).find(track =>
                track.trackName.includes('video-composer-presentation')
              )
            )
        );
      };
      updatePresentationParticipant();

      room.on('trackPublished', updatePresentationParticipant);
      room.on('trackUnpublished', updatePresentationParticipant);
      room.on('participantDisconnected', updatePresentationParticipant);

      // the room object does not emit 'trackPublished' events for the localParticipant,
      // so we need to listen for them here.
      room.localParticipant.on('trackPublished', updatePresentationParticipant);
      room.localParticipant.on('trackUnpublished', updatePresentationParticipant);
      return () => {
        room.off('trackPublished', updatePresentationParticipant);
        room.off('trackUnpublished', updatePresentationParticipant);
        room.off('participantDisconnected', updatePresentationParticipant);

        room.localParticipant.off('trackPublished', updatePresentationParticipant);
        room.localParticipant.off('trackUnpublished', updatePresentationParticipant);
      };
    }
  }, [room]);

  return presentationParticipant;
}
