/* global Twilio Runtime */
'use strict';

module.exports.handler = async (context, event, callback) => {
  const { user_identity, room_sid, hand_raised } = event;

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

  if (!room_sid) {
    response.setStatusCode(400);
    response.setBody({
      error: {
        message: 'missing room_sid',
        explanation: 'The room_sid parameter is missing.',
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
  const syncClient = client.sync.services(context.SYNC_SERVICE_SID);

  try {
    const raisedHandsMapName = `raised_hands-${room_sid}`;

    if (hand_raised) {
      // Add to map
      await syncClient.syncMaps(raisedHandsMapName).syncMapItems.create({ key: user_identity, data: {} });
    } else {
      // Remove from map
      await syncClient.syncMaps(raisedHandsMapName).syncMapItems(user_identity).remove();
    }
  } catch (e) {
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

  response.setStatusCode(200);
  response.setBody({
    sent: true,
  });

  return callback(null, response);
};
