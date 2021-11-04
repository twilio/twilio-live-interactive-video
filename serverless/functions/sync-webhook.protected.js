'use strict';

exports.handler = async function (context, event, callback) {
  const common = require(Runtime.getAssets()['/common.js'].path);
  const { response } = common(context, event, callback);
  const client = context.getTwilioClient();

  if (event.EventType === 'endpoint_disconnected') {
    // Remove user from the raised hands map
    try {
      const streamSyncClient = await client.sync.services(event.ServiceSid);
      await streamSyncClient.syncMaps('raised_hands').syncMapItems(event.Identity).remove();
    } catch (e) {
      const notFoundError = 20404;

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
  }

  return callback(null, response);
};
