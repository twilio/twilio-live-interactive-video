import { useEffect, useRef } from 'react';
import { useEnqueueSnackbar } from '../useSnackbar/useSnackbar';
import useIsRecording from '../useIsRecording/useIsRecording';

export default function useRecordingNotifications() {
  const prevRecordingInfo = useRef<ReturnType<typeof useIsRecording>>();
  const recordingInfo = useIsRecording();
  const enqueueSnackbar = useEnqueueSnackbar();

  useEffect(() => {
    // Show "Recording in progress" snackbar when a user joins a room that is recording
    if (recordingInfo.isRecording && !prevRecordingInfo.current) {
      enqueueSnackbar({
        headline: 'Recording in progress',
        message: '',
        variant: 'info',
      });
    }
  }, [recordingInfo.isRecording]);

  useEffect(() => {
    // Show "Recording error" snackbar when there is a recording error.
    if (recordingInfo.recordingError && prevRecordingInfo.current?.recordingError === null) {
      enqueueSnackbar({
        headline: 'Recording Error',
        message: 'There was a problem recording the contents of this stream. Please try again.',
        variant: 'error',
      });
    }
  }, [recordingInfo.isRecording]);

  useEffect(() => {
    prevRecordingInfo.current = recordingInfo;
  }, [recordingInfo]);
}
