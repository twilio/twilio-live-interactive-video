'use strict';

exports.handler = async function (context, event, callback) {
  const common = require(Runtime.getAssets()['/common.js'].path);
  const { response, createErrorHandler } = common(context, event, callback);
  const client = context.getTwilioClient();

  if (event.EventType === 'endpoint_disconnected') {
    const notFoundError = 20404;

    // Get stream sync client
    const streamSyncClient = await client.sync
      .services(event.ServiceSid)
      .catch(createErrorHandler('error getting stream sync client'));

    // Remove user from speakers map
    await streamSyncClient
      .syncMaps('speakers')
      .syncMapItems(event.Identity)
      .remove()
      .catch((e) => {
        if (e.code !== notFoundError) {
          createErrorHandler('error removing user from speakers map')(e);
        }
      });

    // Remove user from raised hands map

    await streamSyncClient
      .syncMaps('raised_hands')
      .syncMapItems(event.Identity)
      .remove()
      .catch((e) => {
        if (e.code !== notFoundError) {
          createErrorHandler('error removing user from raised hands map')(e);
        }
      });

    // Remove user from viewers map
    await streamSyncClient
      .syncMaps('viewers')
      .syncMapItems(event.Identity)
      .remove()
      .catch((e) => {
        if (e.code !== notFoundError) {
          createErrorHandler('error removing user from viewers map')(e);
        }
      });
  }

  return callback(null, response);
};
