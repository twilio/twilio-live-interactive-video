import { useEffect, useRef } from 'react';
import { useEnqueueSnackbar } from '../useSnackbar/useSnackbar';
import useIsRecording from '../useIsRecording/useIsRecording';
import { useAppState } from '../../state';

export default function useRecordingNotifications() {
  const prevRecordingInfo = useRef<ReturnType<typeof useIsRecording>>();
  const recordingInfo = useIsRecording();
  const enqueueSnackbar = useEnqueueSnackbar();
  const { appState } = useAppState();

  useEffect(() => {
    // Show "Recording in progress" snackbar when a user joins a room that is recording
    if (recordingInfo.isRecording && !prevRecordingInfo.current?.isRecording) {
      enqueueSnackbar({
        headline: 'Recording is in progress',
        message: '',
        variant: 'info',
      });
    }
  }, [recordingInfo.isRecording, enqueueSnackbar]);

  useEffect(() => {
    // Show "Recording error" snackbar when there is a recording error, but only show the error to the host.
    if (
      recordingInfo.recordingError &&
      prevRecordingInfo.current?.recordingError === null &&
      appState.participantType === 'host'
    ) {
      enqueueSnackbar({
        headline: 'Recording Error',
        message: 'There was a problem recording the contents of this stream. Please try again.',
        variant: 'error',
      });
    }
  }, [recordingInfo, enqueueSnackbar]);

  useEffect(() => {
    prevRecordingInfo.current = recordingInfo;
  }, [recordingInfo]);
}
