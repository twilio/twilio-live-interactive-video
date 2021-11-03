/* global Twilio Runtime */
'use strict';

module.exports.handler = async (context, event, callback) => {
  const { user_identity, room_sid } = event;

  let response = new Twilio.Response();
  response.appendHeader('Content-Type', 'application/json');

  const client = context.getTwilioClient();

  try {
    // Set speaker_invite to true
    const backendStorageSyncClient = await client.sync.services(context.BACKEND_STORAGE_SYNC_SERVICE_SID);
    const streamMapItem = await backendStorageSyncClient.syncMaps('streams').syncMapItems(room_sid).fetch();
    const streamSyncClient = await client.sync.services(streamMapItem.data.sync_service_sid);
    const doc = await streamSyncClient.documents(`viewer-${user_identity}`).fetch();
    await streamSyncClient.documents(doc.sid).update({ data: { ...doc.data, speaker_invite: true } });
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
  response.setBody({
    sent: true,
  });

  return callback(null, response);
};
