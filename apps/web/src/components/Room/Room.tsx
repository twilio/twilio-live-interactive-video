import React, { useEffect, useRef } from 'react';
import clsx from 'clsx';
import { makeStyles, Theme } from '@material-ui/core';
import ChatWindow from '../ChatWindow/ChatWindow';
import ParticipantList from '../ParticipantList/ParticipantList';
import MainParticipant from '../MainParticipant/MainParticipant';
import BackgroundSelectionDialog from '../BackgroundSelectionDialog/BackgroundSelectionDialog';
import useChatContext from '../../hooks/useChatContext/useChatContext';
import useVideoContext from '../../hooks/useVideoContext/useVideoContext';
import ParticipantWindow from '../ParticipantWindow/ParticipantWindow';
import { joinStreamAsViewer, connectViewerToPlayer } from '../../state/api/api';
import { useAppState } from '../../state';
import usePlayerContext from '../../hooks/usePlayerContext/usePlayerContext';
import useSyncContext from '../../hooks/useSyncContext/useSyncContext';
import { useEnqueueSnackbar } from '../../hooks/useSnackbar/useSnackbar';
import { Room as IRoom, TwilioError } from 'twilio-video';
import useRecordingNotifications from '../../hooks/useRecordingNotifications/useRecordingNotifications';

const useStyles = makeStyles((theme: Theme) => {
  const totalMobileSidebarHeight = `${theme.sidebarMobileHeight +
    theme.sidebarMobilePadding * 2 +
    theme.participantBorderWidth}px`;
  return {
    container: {
      position: 'relative',
      height: '100%',
      display: 'grid',
      gridTemplateColumns: `1fr ${theme.sidebarWidth}px`,
      gridTemplateRows: '100%',
      [theme.breakpoints.down('sm')]: {
        gridTemplateColumns: `100%`,
        gridTemplateRows: `calc(100% - ${totalMobileSidebarHeight}) ${totalMobileSidebarHeight}`,
      },
    },
    rightDrawerOpen: { gridTemplateColumns: `1fr ${theme.sidebarWidth}px ${theme.rightDrawerWidth}px` },
  };
});

export default function Room() {
  const classes = useStyles();
  const { isChatWindowOpen } = useChatContext();
  const { isBackgroundSelectionOpen, room } = useVideoContext();
  const { connect: playerConnect } = usePlayerContext();
  const { registerUserDocument } = useSyncContext();
  const { appState, appDispatch } = useAppState();
  const setPreventAutomaticJoinStreamAsViewerRef = useRef(false);
  const enqueueSnackbar = useEnqueueSnackbar();

  /**
   * Here we listen for a custom event "setPreventAutomaticJoinStreamAsViewer" which is emitted
   * whenever a speaker clicks on the "Leave Event" button or the "Leave and View Event" button.
   * This is needed because the speaker can also leave the event if they are removed by the host.
   * All of these scenarios result in identical events ("disconnected"), so we needed a way to
   * prevent speakers from automatically re-joining the stream as a viewer whenever they click on
   * the "Leave Event" button.
   */

  useEffect(() => {
    if (room) {
      const handleSetPreventAutomaticJoinStreamAsViewer = () =>
        (setPreventAutomaticJoinStreamAsViewerRef.current = true);
      room.on('setPreventAutomaticJoinStreamAsViewer', handleSetPreventAutomaticJoinStreamAsViewer);

      return () => {
        room.off('setPreventAutomaticJoinStreamAsViewer', handleSetPreventAutomaticJoinStreamAsViewer);
      };
    }
  }, [room]);

  useEffect(() => {
    if (room) {
      setPreventAutomaticJoinStreamAsViewerRef.current = false;

      const handleConnectToPlayer = async (_: IRoom, error: TwilioError) => {
        if (!error && !setPreventAutomaticJoinStreamAsViewerRef.current) {
          appDispatch({ type: 'set-is-loading', isLoading: true });
          try {
            const { data } = await joinStreamAsViewer(room.localParticipant.identity, room.name);
            await playerConnect(data.token);
            await connectViewerToPlayer(appState.participantName, appState.eventName);
            registerUserDocument(`user-${room.localParticipant.identity}`);
            enqueueSnackbar({
              headline: 'Moved to viewers',
              message: 'You have been moved to viewers by the host.',
              variant: 'warning',
            });
            appDispatch({ type: 'set-is-loading', isLoading: false });
          } catch (err) {
            console.log(`Error moving to stream: ${err.message}`, err);
            appDispatch({ type: 'set-is-loading', isLoading: false });
          }
        }
      };
      room.on('disconnected', handleConnectToPlayer);

      return () => {
        room.off('disconnected', handleConnectToPlayer);
      };
    }
  }, [
    room,
    playerConnect,
    registerUserDocument,
    appDispatch,
    appState.participantName,
    appState.eventName,
    enqueueSnackbar,
  ]);

  useRecordingNotifications();

  return (
    <div
      className={clsx(classes.container, {
        [classes.rightDrawerOpen]: isChatWindowOpen || isBackgroundSelectionOpen || appState.isParticipantWindowOpen,
      })}
    >
      <MainParticipant />
      <ParticipantList />
      <ChatWindow />
      <ParticipantWindow />
      <BackgroundSelectionDialog />
    </div>
  );
}
