'use strict';

exports.handler = async function (context, event, callback) {
  const common = require(Runtime.getAssets()['/common.js'].path);
  const { response } = common(context, event, callback);
  const client = context.getTwilioClient();

  if (event.EventType === 'endpoint_disconnected') {
    const notFoundError = 20404;
    let streamSyncClient;
 
    // Get stream sync client
    try {
      streamSyncClient = await client.sync.services(event.ServiceSid);
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
      await streamSyncClient.syncMaps('speakers').syncMapItems(event.Identity).remove();
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

    // Remove user from raised hands map
    try {
      await streamSyncClient.syncMaps('raised_hands').syncMapItems(event.Identity).remove();
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

    // Remove user from viewers map
    try {
      await streamSyncClient.syncMaps('viewers').syncMapItems(event.Identity).remove();
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
  }

  return callback(null, response);
};
