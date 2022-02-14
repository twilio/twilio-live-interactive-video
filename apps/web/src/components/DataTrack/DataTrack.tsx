import { useEffect } from 'react';
import { DataTrack as IDataTrack } from 'twilio-video';
import { useEnqueueSnackbar } from '../../hooks/useSnackbar/useSnackbar';
import useLocalAudioToggle from '../../hooks/useLocalAudioToggle/useLocalAudioToggle';
import useVideoContext from '../../hooks/useVideoContext/useVideoContext';

export default function DataTrack({ track }: { track: IDataTrack }) {
  const { room } = useVideoContext();
  const [isAudioEnabled, toggleAudio] = useLocalAudioToggle();
  const enqueueSnackbar = useEnqueueSnackbar();

  useEffect(() => {
    const handleMessage = (message: string | ArrayBuffer) => {
      if (message instanceof ArrayBuffer) {
        try {
          // Here we convert the message to stringified JSON from ArrayBuffer. Sending/receiving ArrayBuffers
          // in the DataTracks helps with interoperability with the iOS Twilio Live App.
          const messageString = new TextDecoder().decode(message);
          const JSONMessage = JSON.parse(messageString);
          if (
            JSONMessage.message_type === 'mute' &&
            JSONMessage.to_participant_identity === room!.localParticipant.identity
          ) {
            if (isAudioEnabled) {
              toggleAudio();
              enqueueSnackbar({
                headline: '',
                message: 'Your microphone has been muted by the host.',
                variant: 'warning',
              });
            }
          }
        } catch (e) {
          console.error('Error parsing data track message: ', e);
        }
      }
    };
    track.on('message', handleMessage);
    return () => {
      track.off('message', handleMessage);
    };
  }, [track, isAudioEnabled, room, toggleAudio, enqueueSnackbar]);

  return null; // This component does not return any HTML, so we will return 'null' instead.
}
