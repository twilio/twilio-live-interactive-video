/* global Twilio Runtime */
'use strict';

module.exports.handler = async (context, event, callback) => {
  const authHandler = require(Runtime.getAssets()['/auth.js'].path);
  authHandler(context, event, callback);

  const { user_identity, stream_name, hand_raised } = event;

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

  if (typeof hand_raised === 'undefined') {
    response.setStatusCode(400);
    response.setBody({
      error: {
        message: 'missing hand_raised',
        explanation: 'The hand_raised parameter is missing.',
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
    createErrorHandler('error getting stream sync client')(e);
  }

  try {
    if (hand_raised) {
      await streamSyncClient.syncMaps('raised_hands').syncMapItems.create({ key: user_identity, data: {} });
    } else {
      await streamSyncClient.syncMaps('raised_hands').syncMapItems(user_identity).remove();
    }
  } catch (e) {
    // Ignore errors relating to removing a syncMapItem that doesn't exist (20404), or creating one that already does exist (54208)
    if (e.code !== 20404 && e.code !== 54208) {
      createErrorHandler('error updating raised hands map')(e);
    }
  }

  response.setStatusCode(200);
  response.setBody({
    sent: true,
  });

  return callback(null, response);
};
