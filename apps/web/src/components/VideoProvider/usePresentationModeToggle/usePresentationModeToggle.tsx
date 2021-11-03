import { useState, useCallback, useRef } from 'react';
import { LogLevels, Track, Room } from 'twilio-video';
import { ErrorCallback } from '../../../types';

interface MediaStreamTrackPublishOptions {
  name?: string;
  priority: Track.Priority;
  logLevel: LogLevels;
}

export default function usePresentationModeToggle(room: Room | null, onError: ErrorCallback) {
  const [isPresenting, setIsPresenting] = useState(false);
  const stopPresentingRef = useRef<() => void>(null!);

  const startPresenting = useCallback(() => {
    navigator.mediaDevices
      .getDisplayMedia({
        audio: false,
        video: {
          frameRate: 10,
          height: 1080,
          width: 1920,
        },
      })
      .then(stream => {
        const track = stream.getTracks()[0];

        // All video tracks are published with 'low' priority. This works because the video
        // track that is displayed in the 'MainParticipant' component will have it's priority
        // set to 'high' via track.setPriority()
        room!.localParticipant
          .publishTrack(track, {
            name: 'video-composer-presentation', // Tracks can be named to easily find them later
            priority: 'low', // Priority is set to high by the subscriber when the video track is rendered
          } as MediaStreamTrackPublishOptions)
          .then(trackPublication => {
            stopPresentingRef.current = () => {
              room!.localParticipant.unpublishTrack(track);
              // TODO: remove this if the SDK is updated to emit this event
              room!.localParticipant.emit('trackUnpublished', trackPublication);
              track.stop();
              setIsPresenting(false);
            };

            track.onended = stopPresentingRef.current;
            setIsPresenting(true);
          })
          .catch(onError);
      })
      .catch(error => {
        // Don't display an error if the user closes the screen share dialog
        if (error.name !== 'AbortError' && error.name !== 'NotAllowedError') {
          onError(error);
        }
      });
  }, [room, onError]);

  const togglePresentationMode = useCallback(() => {
    if (room) {
      !isPresenting ? startPresenting() : stopPresentingRef.current();
    }
  }, [isPresenting, startPresenting, room]);

  return [isPresenting, togglePresentationMode] as const;
}
