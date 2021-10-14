/* global Twilio Runtime */
'use strict';

module.exports.handler = async (context, event, callback) => {
  const { user_identity, room_sid } = event;

  let response = new Twilio.Response();
  response.appendHeader('Content-Type', 'application/json');

  const client = context.getTwilioClient();
  const syncClient = client.sync.services(context.SYNC_SERVICE_SID);

  try {
    // Set speaker_invite to true
    const doc = await syncClient.documents(`viewer-${room_sid}-${user_identity}`).fetch();
    await syncClient.documents(doc.sid).update({ data: { ...doc.data, speaker_invite: true } });
  } catch (e) {
    console.error(e);
    response.setStatusCode(500);
    response.setBody({
      error: {
        message: 'error updating viewer document',
        explanation: e.message,
      },
    });
    return callback(null, response);
  }

  response.setStatusCode(200);
  return callback(null, response);
};
