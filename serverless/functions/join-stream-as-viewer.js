/* global Twilio Runtime */
'use strict';

const AccessToken = Twilio.jwt.AccessToken;
const SyncGrant = AccessToken.SyncGrant;
const ChatGrant = AccessToken.ChatGrant;
const MAX_ALLOWED_SESSION_DURATION = 14400;

module.exports.handler = async (context, event, callback) => {
  const authHandler = require(Runtime.getAssets()['/auth.js'].path);
  authHandler(context, event, callback);

  const common = require(Runtime.getAssets()['/common.js'].path);
  const { getPlaybackGrant } = common(context, event, callback);

  const { user_identity, stream_name } = event;

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

  let room, streamDocument, viewerDocument;

  const client = context.getTwilioClient();
  const syncClient = client.sync.services(context.SYNC_SERVICE_SID);

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

  const viewerDocumentName = `viewer-${room.sid}-${user_identity}`;
  // Create viewer document
  try {
    viewerDocument = await syncClient.documents.create({
      uniqueName: viewerDocumentName,
    });
  } catch (e) {
    // Ignore "Unique name already exists" error
    if (e.code !== 54301) {
      console.error(e);
      response.setStatusCode(500);
      response.setBody({
        error: {
          message: 'error creating viewer document',
          explanation: e.message,
        },
      });
      return callback(null, response);
    }
  }

  // Update viewer document to set speaker_invite to false.
  // This is done outside of the viewer document creation to account
  // for viewers that may already have a viewer document
  try {
    await syncClient.documents(viewerDocumentName).update({
      data: { speaker_invite: false },
    });
  } catch (e) {
    console.error(e);
    response.setStatusCode(500);
    response.setBody({
      error: {
        message: 'error updating viewer  document',
        explanation: e.message,
      },
    });
    return callback(null, response);
  }

  // Give user read access to viewer document
  try {
    await syncClient
      .documents(viewerDocumentName)
      .documentPermissions(user_identity)
      .update({ read: true, write: false, manage: false });
  } catch (e) {
    response.setStatusCode(500);
    response.setBody({
      error: {
        message: 'error adding read access to viewer document',
        explanation: e.message,
      },
    });
    return callback(null, response);
  }

  // Give user read access to raised hands map
  try {
    await syncClient
      .syncMaps(`raised_hands-${room.sid}`)
      .syncMapPermissions(user_identity)
      .update({ read: true, write: false, manage: false });
  } catch (e) {
    response.setStatusCode(500);
    response.setBody({
      error: {
        message: 'error adding read access to raised hands map',
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

  let playbackGrant;
  try {
    playbackGrant = await getPlaybackGrant(streamDocument.data.player_streamer_sid);
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

  // Create token
  const token = new AccessToken(context.ACCOUNT_SID, context.TWILIO_API_KEY_SID, context.TWILIO_API_KEY_SECRET, {
    ttl: MAX_ALLOWED_SESSION_DURATION,
  });

  // Add chat grant to token
  const chatGrant = new ChatGrant({
    serviceSid: context.CONVERSATIONS_SERVICE_SID,
  });
  token.addGrant(chatGrant);

  // Add participant's identity to token
  token.identity = event.user_identity;

  // Add player grant to token
  token.addGrant({
    key: 'player',
    player: playbackGrant,
    toPayload: () => playbackGrant,
  });

  // Add sync grant to token
  const syncGrant = new SyncGrant({ serviceSid: context.SYNC_SERVICE_SID });
  token.addGrant(syncGrant);

  // Return token
  response.setStatusCode(200);
  response.setBody({
    token: token.toJwt(),
    sync_object_names: {
      raised_hands_map: `raised_hands-${room.sid}`,
      viewer_document: `viewer-${room.sid}-${user_identity}`,
    },
    room_sid: room.sid,
  });

  callback(null, response);
};
