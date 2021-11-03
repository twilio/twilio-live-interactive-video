/* global Twilio Runtime */
'use strict';

module.exports.handler = async (context, event, callback) => {
  const { user_identity, stream_name, hand_raised } = event;

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
    let backendStorageSyncClient = await client.sync.services(context.BACKEND_STORAGE_SYNC_SERVICE_SID);
    let streamMapItem = await backendStorageSyncClient.syncMaps('streams').syncMapItems(room.sid).fetch();
    streamSyncClient = client.sync.services(streamMapItem.data.sync_service_sid);
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

  const raisedHandsMapName = `raised_hands`;

  try {
    if (hand_raised) {
      await streamSyncClient.syncMaps(raisedHandsMapName).syncMapItems.create({ key: user_identity, data: { } });
    } else {
      await streamSyncClient.syncMaps(raisedHandsMapName).syncMapItems(user_identity).remove();
    }
  } catch (e) {
    // Ignore errors relating to removing a syncMapItem that doesn't exist (20404), or creating one that already does exist (54208)
    if (e.code !== 20404 && e.code !== 54208) {
      console.error(e);
      response.setStatusCode(500);
      response.setBody({
        error: {
          message: 'error updating raised hands map',
          explanation: e.message,
        },
      });
      return callback(null, response);
    }
  }

  response.setStatusCode(200);
  response.setBody({
    sent: true,
  });

  return callback(null, response);
};
