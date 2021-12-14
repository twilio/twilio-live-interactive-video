/* global Twilio Runtime */
'use strict';

module.exports.handler = async (context, event, callback) => {
  const authHandler = require(Runtime.getAssets()['/auth.js'].path);
  authHandler(context, event, callback);

  const { user_identity, stream_name } = event;
  const common = require(Runtime.getAssets()['/common.js'].path);
  const { getStreamMapItem } = common(context, event, callback);

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

  let room, streamSyncClient;

  try {
    // See if a room already exists
    room = await client.video.rooms(stream_name).fetch();
  } catch (e) {
    console.error(e);
    response.setStatusCode(500);
    response.setBody({
      error: {
        message: 'error finding room',
        explanation: e.message,
      },
    });
    return callback(null, response);
  }

  // Get stream sync client
  try {
    let streamMapItem = await getStreamMapItem(room.sid);
    streamSyncClient = await client.sync.services(streamMapItem.data.sync_service_sid);
  } catch (e) {
    response.setStatusCode(500);
    response.setBody({
      error: {
        message: 'error getting stream sync client',
        explanation: e.message,
      },
    });
    return callback(null, response);
  }

  // Add user to viewers map
  try {
    await streamSyncClient.syncMaps('viewers').syncMapItems.create({ key: user_identity, data: {} });
  } catch (e) {
    const alreadyExistsError = 54208;

    if (e.code !== alreadyExistsError) {
      console.error(e);
      response.setStatusCode(500);
      response.setBody({
        error: {
          message: 'error adding user to viewers map',
          explanation: e.message,
        },
      });
      return callback(null, response);
    }
  }

  response.setStatusCode(200);
  response.setBody({
    success: true,
  });

  return callback(null, response);
};
