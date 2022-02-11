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
    // End the video room which will cause everything else to be cleaned up in the rooms webhook
    await client.video.rooms(stream_name).update({ status: 'completed' });

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
