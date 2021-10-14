/* global Twilio Runtime */
'use strict';

const AccessToken = Twilio.jwt.AccessToken;
const MAX_ALLOWED_SESSION_DURATION = 14400;

module.exports.handler = async (context, event, callback) => {
  const common = require(Runtime.getAssets()['/common.js'].path);
  const { getPlaybackGrant } = common(context, event, callback);

  const { user_identity, room_name } = event;

  let response = new Twilio.Response();
  response.appendHeader('Content-Type', 'application/json');

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

  if (!room_name) {
    response.setStatusCode(400);
    response.setBody({
      error: {
        message: 'missing room_name',
        explanation: 'The room_name parameter is missing.',
      },
    });
    return callback(null, response);
  }

  let room, streamDocument;

  const client = context.getTwilioClient();
  const syncClient = client.sync.services(context.SYNC_SERVICE_SID);

  try {
    // See if a room already exists
    room = await client.video.rooms(room_name).fetch();
  } catch (e) {
    response.setStatusCode(500);
    response.setBody({
      error: {
        message: 'error finding room',
        explanation: e.message,
      },
    });
    return callback(null, response);
  }

  try {
    // Get playerStreamerSid from stream document
    streamDocument = await syncClient.documents(`stream-${room.sid}`).fetch();
  } catch (e) {
    response.setStatusCode(500);
    response.setBody({
      error: {
        message: 'error finding stream document',
        explanation: e.message,
      },
    });
    return callback(null, response);
  }

  let playbackGrant = streamDocument.data.playbackGrant;
  if (!playbackGrant || !playbackGrant.grantExpiration || playbackGrant.grantExpiration < new Date().getTime()) {
    try {
      playbackGrant = streamDocument.data.playbackGrant = await getPlaybackGrant(streamDocument.data.playerStreamerSid);
      await syncClient.documents(`stream-${room.sid}`).update({data: streamDocument.data});
    } catch (e) {
      console.error(e);
      response.setStatusCode(500);
      response.setBody({
        error: {
          message: 'error getting playback grant',
          explanation: e.message,
        },
      });
      return callback(null, response);
    }
  }

  // Create token
  const token = new AccessToken(context.ACCOUNT_SID, context.TWILIO_API_KEY_SID, context.TWILIO_API_KEY_SECRET, {
    ttl: MAX_ALLOWED_SESSION_DURATION,
  });

  // Add participant's identity to token
  token.identity = event.user_identity;

  // Add player grant to token
  token.addGrant({
    key: 'player',
    player: playbackGrant.grant,
    toPayload: () => playbackGrant.grant,
  });

  // Return token
  response.setStatusCode(200);
  response.setBody({
    token: token.toJwt(),
  });

  callback(null, response);
};
