import { useEffect, useState } from 'react';
import { StreamDocument } from '../../types';
import useSyncContext from '../useSyncContext/useSyncContext';
import useVideoContext from '../useVideoContext/useVideoContext';

export default function useIsRecording() {
  const { room } = useVideoContext();
  const [isRecording, setIsRecording] = useState(Boolean(room?.isRecording));
  const { streamDocument } = useSyncContext();

  useEffect(() => {
    if (streamDocument) {
      setIsRecording((streamDocument?.data as StreamDocument).recording.is_recording);
      const handleUpdate = (update: { data: StreamDocument }) => setIsRecording(update.data.recording.is_recording);

      streamDocument.on('updated', handleUpdate);
      return () => {
        streamDocument.off('updated', handleUpdate);
      };
    }
  }, [streamDocument]);

  return isRecording;
}
