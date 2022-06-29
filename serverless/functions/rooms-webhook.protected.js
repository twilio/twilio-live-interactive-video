'use strict';

exports.handler = async function (context, event, callback) {
  const common = require(Runtime.getAssets()['/common.js'].path);
  const { axiosClient, response, getStreamMapItem, createErrorHandler } = common(context, event, callback);

  const client = context.getTwilioClient();

  const { StatusCallbackEvent, RoomSid } = event;
  const notFoundError = 20404;
  const videoComposerIdentityPrefix = 'video-composer';
  let streamSyncClient;

  switch (StatusCallbackEvent) {
    case 'participant-connected':
      if (event.ParticipantIdentity.startsWith(videoComposerIdentityPrefix)) {
        break; // Ignore the video composer participant
      }

      // Get stream sync client
      try {
        const streamMapItem = await getStreamMapItem(RoomSid);
        streamSyncClient = await client.sync.services(streamMapItem.data.sync_service_sid);
      } catch (e) {
        createErrorHandler('error getting stream sync client')(e);
      }

      // Remove user from viewers map

      await streamSyncClient
        .syncMaps('viewers')
        .syncMapItems(event.ParticipantIdentity)
        .remove()
        .catch((e) => {
          if (e.code !== notFoundError) {
            createErrorHandler('error removing user from viewers map')(e);
          }
        });

      // Remove user from raised hands map
      await streamSyncClient
        .syncMaps('raised_hands')
        .syncMapItems(event.ParticipantIdentity)
        .remove()
        .catch((e) => {
          if (e.code !== notFoundError) {
            createErrorHandler('error removing user from raised hands map')(e);
          }
        });

      // Add user to the speakers map. There is only one host and they are added to the speakers map
      // when the stream is created. So all new speakers that are added here will not be host.
      await streamSyncClient
        .syncMaps('speakers')
        .syncMapItems.create({
          key: event.ParticipantIdentity,
          data: { host: false },
        })
        .catch((e) => {
          const alreadyExistsError = 54208;
          if (e.code !== alreadyExistsError) {
            createErrorHandler('error adding user to speakers map')(e);
          }
        });

      break;
    case 'participant-disconnected':
      if (event.ParticipantIdentity.startsWith(videoComposerIdentityPrefix)) {
        break; // Ignore the video composer participant
      }

      // Get stream sync client
      try {
        const streamMapItem = await getStreamMapItem(RoomSid);
        streamSyncClient = await client.sync.services(streamMapItem.data.sync_service_sid);
      } catch (e) {
        createErrorHandler('error getting stream sync client')(e);
      }

      // Remove user from speakers map
      await streamSyncClient
        .syncMaps('speakers')
        .syncMapItems(event.ParticipantIdentity)
        .remove()
        .catch((e) => {
          if (e.code !== notFoundError) {
            createErrorHandler('error removing user from speakers map')(e);
          }
        });

      break;
    case 'room-ended':
      try {
        const backendStorageSyncClient = await client.sync.services(context.BACKEND_STORAGE_SYNC_SERVICE_SID);
        const streamMapItem = await backendStorageSyncClient.syncMaps('streams').syncMapItems(RoomSid).fetch();

        // Get playerStreamerSid and mediaProcessorSid from stream map item
        const { player_streamer_sid, media_processor_sid } = streamMapItem.data;

        // Stop mediaProcessor
        await axiosClient(`MediaProcessors/${media_processor_sid}`, {
          method: 'post',
          data: 'Status=ENDED',
        });

        // Stop playerStreamer
        await axiosClient(`PlayerStreamers/${player_streamer_sid}`, {
          method: 'post',
          data: 'Status=ENDED',
        });

        // Delete stream service
        await client.sync.services(streamMapItem.data.sync_service_sid).remove();

        // Delete stream map item

        await backendStorageSyncClient.syncMaps('streams').syncMapItems(RoomSid).remove();

        console.log('Deleted stream: ', RoomSid);
        console.log('Ended MediaProcessor: ', media_processor_sid);
        console.log('Ended PlayerStreamer: ', player_streamer_sid);
      } catch (e) {
        createErrorHandler('error deleting stream')(e);
      }

      break;

    default:
      break;
  }

  response.setBody({
    deleted: true,
  });

  callback(null, response);
};
