import React from 'react';
import useTrack from '../../hooks/useTrack/useTrack';
import AudioTrack from '../AudioTrack/AudioTrack';
import VideoTrack from '../VideoTrack/VideoTrack';
import DataTrack from '../DataTrack/DataTrack';

import { LocalTrackPublication, Participant, RemoteTrackPublication, Track } from 'twilio-video';

interface PublicationProps {
  publication: LocalTrackPublication | RemoteTrackPublication;
  participant: Participant;
  isLocalParticipant?: boolean;
  videoOnly?: boolean;
  videoPriority?: Track.Priority | null;
}

export default function Publication({ publication, isLocalParticipant, videoOnly, videoPriority }: PublicationProps) {
  const track = useTrack(publication);

  if (!track) return null;

  switch (track.kind) {
    case 'video':
      return (
        <VideoTrack
          track={track}
          priority={videoPriority}
          isLocal={track.name.includes('camera') && isLocalParticipant}
        />
      );
    case 'audio':
      return videoOnly ? null : <AudioTrack track={track} />;
    case 'data':
      // We use videoOnly here because, like audio tracks, we only ever want one data track rendered at a time.
      return videoOnly ? null : <DataTrack track={track} />;
    default:
      return null;
  }
}
