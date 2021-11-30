'use strict';

exports.handler = async function (context, event, callback) {
  const authHandler = require(Runtime.getAssets()['/auth.js'].path);
  authHandler(context, event, callback);

  const common = require(Runtime.getAssets()['/common.js'].path);
  const { axiosClient, response } = common(context, event, callback);

  const client = context.getTwilioClient();
  const backendStrageSyncClient = client.sync.services(context.BACKEND_STORAGE_SYNC_SERVICE_SID);

  const { stream_name } = event;

  try {
    // End room
    const room = await client.video.rooms(stream_name).update({ status: 'completed' });

    // Fetch stream map item
    const streamMapItem = await backendStrageSyncClient.syncMaps('streams').syncMapItems(room.sid).fetch();

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
    await backendStrageSyncClient.syncMaps('streams').syncMapItems(room.sid).remove();

    console.log('deleted: ', stream_name);
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

  response.setBody({
    deleted: true,
  });

  callback(null, response);
};
