/* global Twilio Runtime */
'use strict';

const AccessToken = Twilio.jwt.AccessToken;
const VideoGrant = AccessToken.VideoGrant;
const ChatGrant = AccessToken.ChatGrant;
const SyncGrant = AccessToken.SyncGrant;
const MAX_ALLOWED_SESSION_DURATION = 14400;

module.exports.handler = async (context, event, callback) => {
  const { ACCOUNT_SID, TWILIO_API_KEY_SID, TWILIO_API_KEY_SECRET, CONVERSATIONS_SERVICE_SID } = context;

  const authHandler = require(Runtime.getAssets()['/auth.js'].path);
  authHandler(context, event, callback);

  const { user_identity, stream_name } = event;

  const common = require(Runtime.getAssets()['/common.js'].path);
  const { getStreamMapItem, createErrorHandler } = common(context, event, callback);

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

  // See if a room already exists
  room = await client.video.rooms(stream_name).fetch().catch(createErrorHandler('error finding room'));

  // Fetch stream map item
  streamMapItem = await getStreamMapItem(room.sid).catch(createErrorHandler('error finding stream map item'));

  const streamSyncClient = client.sync.services(streamMapItem.data.sync_service_sid);

  const userDocumentName = `user-${user_identity}`;
  // Create user document
  await streamSyncClient.documents
    .create({
      uniqueName: userDocumentName,
    })
    .catch((error) => {
      // Ignore "Unique name already exists" error
      if (error.code !== 54301) {
        createErrorHandler('error creating user document')(error);
      }
    });

  // Give user read access to stream document
  await streamSyncClient
    .documents('stream')
    .documentPermissions(user_identity)
    .update({ read: true, write: false, manage: false })
    .catch(createErrorHandler('error adding read access to stream document.'));

  // Give user read access to user document
  await streamSyncClient
    .documents(userDocumentName)
    .documentPermissions(user_identity)
    .update({ read: true, write: false, manage: false })
    .catch(createErrorHandler('error adding read access to user document'));

  // Give user read access to speakers map
  await streamSyncClient
    .syncMaps('speakers')
    .syncMapPermissions(user_identity)
    .update({ read: true, write: false, manage: false })
    .catch(createErrorHandler('error adding read access to speakers map'));

  // Give user read access to raised hands map
  await streamSyncClient
    .syncMaps('raised_hands')
    .syncMapPermissions(user_identity)
    .update({ read: true, write: false, manage: false })
    .catch(createErrorHandler('error adding read access to raised hands map'));

  // Give user read access to viewers map
  await streamSyncClient
    .syncMaps('viewers')
    .syncMapPermissions(user_identity)
    .update({ read: true, write: false, manage: false })
    .catch(createErrorHandler('error adding read access to viewers map'));

  const conversationsClient = client.conversations.services(CONVERSATIONS_SERVICE_SID);

  // Find conversation
  conversation = await conversationsClient
    .conversations(room.sid)
    .fetch()
    .catch(createErrorHandler('error finding conversation'));

  // Add participant to conversation
  await conversationsClient
    .conversations(room.sid)
    .participants.create({ identity: user_identity })
    .catch((error) => {
      // Ignore "Participant already exists" error (50433)
      if (error.code !== 50433) {
        createErrorHandler('error creating conversation participant')(error);
      }
    });

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
      raised_hands_map: 'raised_hands',
      user_document: userDocumentName,
      stream_document: 'stream',
    },
  });
  return callback(null, response);
};
