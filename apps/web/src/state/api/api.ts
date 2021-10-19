import axios from 'axios';

export const apiClient = axios.create({
  baseURL: '/',
  headers: {
    'content-type': 'application/json',
  },
});

export const createStream = (user_identity: string, stream_name: string) =>
  apiClient.post<{
    token: string;
    sync_object_names: {
      raised_hands_map: string;
    };
  }>('create-stream', {
    user_identity,
    stream_name,
  });

export const joinStreamAsSpeaker = (user_identity: string, stream_name: string) =>
  apiClient.post<{
    token: string;
    sync_object_names: {
      raised_hands_map: string;
    };
  }>('join-stream-as-speaker', {
    user_identity,
    stream_name,
  });

export const joinStreamAsViewer = (user_identity: string, stream_name: string) =>
  apiClient.post<{
    token: string;
    room_sid: string;
    sync_object_names: {
      raised_hands_map: string;
      viewer_document: string;
    };
  }>('join-stream-as-viewer', {
    user_identity,
    stream_name,
  });

export const raiseHand = (user_identity: string, stream_name: string, hand_raised: boolean) =>
  apiClient.post('raise-hand', {
    user_identity,
    stream_name,
    hand_raised,
  });

export const sendSpeakerInvite = (user_identity: string, room_sid: string) =>
  apiClient.post('send-speaker-invite', {
    user_identity,
    room_sid,
  });

export const deleteStream = (stream_name: string) =>
  apiClient.post('delete-stream', {
    stream_name,
  });
