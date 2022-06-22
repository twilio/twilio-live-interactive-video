'use strict';

exports.handler = async function (context, event, callback) {
  const common = require(Runtime.getAssets()['/common.js'].path);
  const { getStreamMapItem, createErrorHandler } = common(context, event, callback);

  const client = context.getTwilioClient();

  const { StatusCallbackEvent, ExtensionContext } = event;

  switch (StatusCallbackEvent) {
    case 'recording-failed':
      let streamSyncClient;

      // Get stream sync client
      try {
        const roomName = JSON.parse(ExtensionContext).room.name;
        let streamMapItem = await getStreamMapItem(roomName);
        streamSyncClient = await client.sync.services(streamMapItem.data.sync_service_sid);
      } catch (e) {
        createErrorHandler('error getting the stream client.')(e);
      }

      const doc = await streamSyncClient.documents('stream').fetch();
      await streamSyncClient
        .documents(doc.sid)
        .update({ data: { ...doc.data, recording: { is_recording: false, error: event.ErrorMessage } } })
        .catch(createErrorHandler('error updating stream document'));

      break;
    default:
      break;
  }

  callback(null, 'ok');
};
