'use strict';

exports.handler = async function (context, event, callback) {
  const common = require(Runtime.getAssets()['/common.js'].path);
  const { axiosClient, response, getStreamMapItem } = common(context, event, callback);

  const client = context.getTwilioClient();

  const { StatusCallbackEvent, RoomSid } = event;
  const notFoundError = 20404;
  const videoComposerIdentityPrefix = 'video-composer';
  let streamSyncClient;

  switch(StatusCallbackEvent) {
    case 'participant-connected':
      if (event.ParticipantIdentity.startsWith(videoComposerIdentityPrefix)) {
        break; // Ignore the video composer participant
      }

      // Get stream sync client
      try {
        const streamMapItem = await getStreamMapItem(RoomSid);
        streamSyncClient = await client.sync.services(streamMapItem.data.sync_service_sid);
      } catch (e) {
        console.error(e);
        response.setStatusCode(500);
        response.setBody({
          error: {
            message: 'error getting stream sync client',
            explanation: e.message,
          },
        });
        return callback(null, response);
      }
  
      // Remove user from viewers map
      try {
        await streamSyncClient.syncMaps('viewers').syncMapItems(event.ParticipantIdentity).remove();
      } catch (e) {
        if (e.code !== notFoundError) {
          console.error(e);
          response.setStatusCode(500);
          response.setBody({
            error: {
              message: 'error removing user from viewers map',
              explanation: e.message,
            },
          });
          return callback(null, response);
        }
      }

      // Remove user from raised hands map 
      try {
        await streamSyncClient.syncMaps('raised_hands').syncMapItems(event.ParticipantIdentity).remove();
      } catch (e) {
        if (e.code !== notFoundError) {
          console.error(e);
          response.setStatusCode(500);
          response.setBody({
            error: {
              message: 'error removing user from raised hands map',
              explanation: e.message,
            },
          });
          return callback(null, response);
        }
      }

      // Add user to speaker map
      try {
        await streamSyncClient.syncMaps('speakers').syncMapItems.create({ key: event.ParticipantIdentity, data: { } });
      } catch (e) {
        const alreadyExistsError = 54208;
    
        if (e.code !== alreadyExistsError) {
          console.error(e);
          response.setStatusCode(500);
          response.setBody({
            error: {
              message: 'error adding user to speakers map',
              explanation: e.message,
            },
          });
          return callback(null, response);
        }
      }
    
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
        console.error(e);
        response.setStatusCode(500);
        response.setBody({
          error: {
            message: 'error getting stream sync client',
            explanation: e.message,
          },
        });
        return callback(null, response);
      }

      // Remove user from speakers map
      try {
        await streamSyncClient.syncMaps('speakers').syncMapItems(event.ParticipantIdentity).remove();
      } catch (e) {
        if (e.code !== notFoundError) {
          console.error(e);
          response.setStatusCode(500);
          response.setBody({
            error: {
              message: 'error removing user from speakers map',
              explanation: e.message,
            },
          });
          return callback(null, response);
        }
      }

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
        console.log(e);
        response.setStatusCode(500);
        response.setBody({
          error: {
            message: 'error deleting stream',
            explanation: e.message,
          },
        });
        return callback(null, response);
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
