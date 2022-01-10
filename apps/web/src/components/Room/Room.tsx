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
import { joinStreamAsViewer } from '../../state/api/api';
import { useAppState } from '../../state';
import usePlayerContext from '../../hooks/usePlayerContext/usePlayerContext';
import useSyncContext from '../../hooks/useSyncContext/useSyncContext';

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
  const { connect } = usePlayerContext();
  const { registerUserDocument } = useSyncContext();
  const { appState } = useAppState();
  const byeRef = useRef(false);

  useEffect(() => {
    if (room) {
      const handleBye = () => (byeRef.current = true);
      room.on('bye', handleBye);

      return () => {
        room.off('bye', handleBye);
      };
    }
  }, [room]);

  useEffect(() => {
    if (room) {
      byeRef.current = false;
      const handleConnectToPlayer = async () => {
        if (!byeRef.current) {
          const { data } = await joinStreamAsViewer(room.localParticipant.identity, room.name);
          await connect(data.token);
          registerUserDocument(data.sync_object_names.user_document);
        }
      };
      room.on('disconnected', handleConnectToPlayer);

      return () => {
        room.off('disconnected', handleConnectToPlayer);
      };
    }
  }, [room, connect, registerUserDocument]);

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
