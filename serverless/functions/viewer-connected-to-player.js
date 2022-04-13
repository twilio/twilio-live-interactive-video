/* global Twilio Runtime */
'use strict';

module.exports.handler = async (context, event, callback) => {
  const authHandler = require(Runtime.getAssets()['/auth.js'].path);
  authHandler(context, event, callback);

  const { user_identity, stream_name } = event;
  const common = require(Runtime.getAssets()['/common.js'].path);
  const { getStreamMapItem, createErrorHandler } = common(context, event, callback);

  if (!user_identity) {
    response.setStatusCode(400);
    response.setBody({
      error: {
        message: 'missing user_identity',
        explanation: 'The user_identity parameter is missing.',
      },
    });
    return callback(null, response);
  }

  if (!stream_name) {
    response.setStatusCode(400);
    response.setBody({
      error: {
        message: 'missing stream_name',
        explanation: 'The stream_name parameter is missing.',
      },
    });
    return callback(null, response);
  }

  let response = new Twilio.Response();
  response.appendHeader('Content-Type', 'application/json');

  const client = context.getTwilioClient();

  let streamSyncClient;

  // See if a room already exists
  const room = await client.video.rooms(stream_name).fetch().catch(createErrorHandler('error finding room'));

  // Get stream sync client
  try {
    let streamMapItem = await getStreamMapItem(room.sid);
    streamSyncClient = await client.sync.services(streamMapItem.data.sync_service_sid);
  } catch (e) {
    createErrorHandler('error finding stream sync client')(e);
  }

  // Add user to viewers map
  await streamSyncClient
    .syncMaps('viewers')
    .syncMapItems.create({ key: user_identity, data: {} })
    .catch((e) => {
      const alreadyExistsError = 54208;

      if (e.code !== alreadyExistsError) {
        createErrorHandler('error adding user to viewers map')(e);
      }
    });

  response.setStatusCode(200);
  response.setBody({
    success: true,
  });

  return callback(null, response);
};
