import { Room, TwilioError } from 'twilio-video';
import { useEffect } from 'react';

import { Callback } from '../../../types';
import { useEnqueueSnackbar } from '../../../hooks/useSnackbar/useSnackbar';

export default function useHandleRoomDisconnection(
  room: Room | null,
  onError: Callback,
  removeLocalAudioTrack: () => void,
  removeLocalVideoTrack: () => void,
  isPresenting: boolean,
  togglePresentationMode: () => void
) {
  const enqueueSnackbar = useEnqueueSnackbar();
  useEffect(() => {
    if (room) {
      const onDisconnected = (_: Room, error: TwilioError) => {
        console.log('disconnect', error);
        if (error?.code === 53118) {
          enqueueSnackbar({
            headline: 'Event has ended',
            message: 'The event has been ended by the host.',
            variant: 'error',
          });
        } else if (error) {
          onError(error);
        }

        removeLocalAudioTrack();
        removeLocalVideoTrack();
        if (isPresenting) {
          togglePresentationMode();
        }
      };

      room.on('disconnected', onDisconnected);
      return () => {
        room.off('disconnected', onDisconnected);
      };
    }
  }, [
    room,
    onError,
    removeLocalAudioTrack,
    removeLocalVideoTrack,
    isPresenting,
    togglePresentationMode,
    enqueueSnackbar,
  ]);
}
