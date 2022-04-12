import { useEffect, useState } from 'react';
import { StreamDocument } from '../../types';
import useSyncContext from '../useSyncContext/useSyncContext';
import useVideoContext from '../useVideoContext/useVideoContext';

export default function useIsRecording() {
  const { room } = useVideoContext();
  const [isRecording, setIsRecording] = useState(Boolean(room?.isRecording));
  const [recordingError, setRecordingError] = useState<null | string>(null);
  const { streamDocument } = useSyncContext();

  useEffect(() => {
    if (streamDocument) {
      setIsRecording((streamDocument?.data as StreamDocument).recording.is_recording);
      setRecordingError((streamDocument?.data as StreamDocument).recording.error);

      const handleUpdate = (update: { data: StreamDocument }) => {
        setIsRecording(update.data.recording.is_recording);
        setRecordingError(update.data.recording.error);
      };

      streamDocument.on('updated', handleUpdate);
      return () => {
        streamDocument.off('updated', handleUpdate);
      };
    }
  }, [streamDocument]);

  return { isRecording, recordingError };
}
