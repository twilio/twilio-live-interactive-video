'use strict';

exports.handler = async function (context, event, callback) {
  const common = require(Runtime.getAssets()['/common.js'].path);
  const { axiosClient, response, getStreamMapItem, createErrorHandler } = common(context, event, callback);

  const client = context.getTwilioClient();

  const { recording_error = false, stream_name } = event;

  let streamSyncClient;

  // See if a room already exists
  const room = await client.video.rooms(stream_name).fetch().catch(createErrorHandler('error finding room'));

  // Get stream sync client
  try {
    let streamMapItem = await getStreamMapItem(room.sid);
    streamSyncClient = await client.sync.services(streamMapItem.data.sync_service_sid);
  } catch (e) {
    createErrorHandler('error getting the stream client.')(e);
  }

  if (recording_error === 'true') {
    const doc = await streamSyncClient.documents('stream').fetch();
    await streamSyncClient
      .documents(doc.sid)
      .update({ data: { ...doc.data, recording: { is_recording: false, error: 'A recording error has occured' } } })
      .catch(createErrorHandler('error updating stream document'));
  }

  callback(null, 'ok');
};
