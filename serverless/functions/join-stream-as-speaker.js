/* global Twilio Runtime */
'use strict';

const AccessToken = Twilio.jwt.AccessToken;
const VideoGrant = AccessToken.VideoGrant;
const ChatGrant = AccessToken.ChatGrant;
const SyncGrant = AccessToken.SyncGrant;
const MAX_ALLOWED_SESSION_DURATION = 14400;

module.exports.handler = async (context, event, callback) => {
  const { ACCOUNT_SID, TWILIO_API_KEY_SID, TWILIO_API_KEY_SECRET, CONVERSATIONS_SERVICE_SID } =
    context;

  const { user_identity, stream_name } = event;

  const common = require(Runtime.getAssets()['/common.js'].path);
  const { getStreamMapItem } = common(context, event, callback);

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

  let room, conversation, streamMapItem;

  const client = context.getTwilioClient();

  try {
    // See if a room already exists
    room = await client.video.rooms(stream_name).fetch();
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

  // Fetch stream map item
  try {
    streamMapItem = await getStreamMapItem(room.sid);
  } catch (e) {
    response.setStatusCode(500);
    response.setBody({
      error: {
        message: 'error finding stream map item',
        explanation: e.message,
      },
    });
    return callback(null, response);
  }

  const streamSyncClient = client.sync.services(streamMapItem.data.sync_service_sid);

  const userDocumentName = `user-${user_identity}`;
  // Create user document
  try {
    await streamSyncClient.documents.create({
      uniqueName: userDocumentName,
    });
  } catch (e) {
    // Ignore "Unique name already exists" error
    if (e.code !== 54301) {
      console.error(e);
      response.setStatusCode(500);
      response.setBody({
        error: {
          message: 'error creating user document',
          explanation: e.message,
        },
      });
      return callback(null, response);
    }
  }

  // Give user read access to user document
  try {
    await streamSyncClient.documents(userDocumentName)
      .documentPermissions(user_identity)
      .update({ read: true, write: false, manage: false })
  } catch (e) {
    response.setStatusCode(500);
    response.setBody({
      error: {
        message: 'error adding read access to user document',
        explanation: e.message,
      },
    });
    return callback(null, response);
  }
  
  // Give user read access to speakers map
  try {
    await streamSyncClient.syncMaps('speakers')
      .syncMapPermissions(user_identity)
      .update({ read: true, write: false, manage: false })
  } catch (e) {
    response.setStatusCode(500);
    response.setBody({
      error: {
        message: 'error adding read access to speakers map',
        explanation: e.message,
      },
    });
    return callback(null, response);
  }
  
  const raisedHandsMapName = `raised_hands`;
  // Give user read access to raised hands map
  try {
    await streamSyncClient.syncMaps(raisedHandsMapName)
      .syncMapPermissions(user_identity)
      .update({ read: true, write: false, manage: false })
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

  // Give user read access to viewers map
  try {
    await streamSyncClient.syncMaps('viewers')
      .syncMapPermissions(user_identity)
      .update({ read: true, write: false, manage: false })
  } catch (e) {
    response.setStatusCode(500);
    response.setBody({
      error: {
        message: 'error adding read access to viewers map',
        explanation: e.message,
      },
    });
    return callback(null, response);
  }

  const conversationsClient = client.conversations.services(CONVERSATIONS_SERVICE_SID);

  try {
    // Find conversation
    conversation = await conversationsClient.conversations(room.sid).fetch();
  } catch (e) {
    console.error(e);
    response.setStatusCode(500);
    response.setBody({
      error: {
        message: 'error finding conversation',
        explanation: 'Something went wrong when finding a conversation.',
      },
    });
    return callback(null, response);
  }

  try {
    // Add participant to conversation
    await conversationsClient.conversations(room.sid).participants.create({ identity: user_identity });
  } catch (e) {
    // Ignore "Participant already exists" error (50433)
    if (e.code !== 50433) {
      console.error(e);
      response.setStatusCode(500);
      response.setBody({
        error: {
          message: 'error creating conversation participant',
          explanation: 'Something went wrong when creating a conversation participant.',
        },
      });
      return callback(null, response);
    }
  }

  // Create token
  const token = new AccessToken(ACCOUNT_SID, TWILIO_API_KEY_SID, TWILIO_API_KEY_SECRET, {
    ttl: MAX_ALLOWED_SESSION_DURATION,
  });

  // Add participant's identity to token
  token.identity = user_identity;

  // Add video grant to token
  const videoGrant = new VideoGrant({ room: stream_name });
  token.addGrant(videoGrant);

  // Add chat grant to token
  const chatGrant = new ChatGrant({ serviceSid: CONVERSATIONS_SERVICE_SID });
  token.addGrant(chatGrant);

  // Add sync grant to token
  const syncGrant = new SyncGrant({ serviceSid: streamMapItem.data.sync_service_sid });
  token.addGrant(syncGrant);

  // Return token
  response.setStatusCode(200);
  response.setBody({
    token: token.toJwt(),
    sync_object_names: {
      speakers_map: 'speakers',
      viewers_map: 'viewers',
      raised_hands_map: `raised_hands`,
      user_document: `user-${user_identity}`,
    },
  });
  return callback(null, response);
};
