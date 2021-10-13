/* global Twilio Runtime */
'use strict';

const AccessToken = Twilio.jwt.AccessToken;
const VideoGrant = AccessToken.VideoGrant;
const MAX_ALLOWED_SESSION_DURATION = 14400;

module.exports.handler = async (context, event, callback) => {
  const { ACCOUNT_SID, TWILIO_API_KEY_SID, TWILIO_API_KEY_SECRET } = context;

  const { user_identity, room_sid, room_name } = event;

  let response = new Twilio.Response();
  response.appendHeader('Content-Type', 'application/json');

  const client = context.getTwilioClient();

  const syncService = client.sync.services(context.SYNC_SERVICE_SID); // TODO: Use other sync client

  // Create token
  const token = new AccessToken(ACCOUNT_SID, TWILIO_API_KEY_SID, TWILIO_API_KEY_SECRET, {
    ttl: MAX_ALLOWED_SESSION_DURATION,
  });

  // Add participant's identity to token
  token.identity = user_identity;

  // Add video grant to token
  const videoGrant = new VideoGrant({ room: room_name });
  token.addGrant(videoGrant);

  // Create raised hands map if it doesn't exist
  try {
    const docName = `viewer-${room_sid}-${user_identity}`;
    console.log(docName);

    const doc = await syncService.documents(docName).fetch();
    console.log(doc);

    const documentDataJSON = doc.data; //JSON.parse(doc.data);

    console.log(documentDataJSON);

    console.log('Test log');

    console.log(`doc json: ${ JSON.stringify(documentDataJSON) }`);

    await doc.update({data: {hand_raised: documentDataJSON.hand_raised, speaker_invite: { video_room_token: token.toJwt()}}});


    // TODO: Should use mutate instead of update
    // doc.mutate(function (remoteData) {
    //   remoteData.video_room_token = token;
    //   return remoteData;
    // });

    // await syncService.documents(`viewer-${room_sid}-${user_identity}`).mutate(function(remoteData) {
    //   remoteData.video_room_token = token;
    //   return remoteData;
    // });

    // await syncService.documents(`viewer-${room_sid}-${user_identity}`).update({'speaker_invite': {'video_room_token': token }});
  } catch (e) {
    response.setStatusCode(500);
    response.setBody({
      error: {
        message: 'error adding room token to viewer doc',
        explanation: e.message,
      },
    });
    return callback(null, response);
  }
  
  // Return token
  response.setStatusCode(200);
  response.setBody({ success: true });
  return callback(null, response);
};
