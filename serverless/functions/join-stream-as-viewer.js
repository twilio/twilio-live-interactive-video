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
  const { getPlaybackGrant, getStreamMapItem, createErrorHandler } = common(context, event, callback);

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

  let room, streamMapItem, userDocument;

  const client = context.getTwilioClient();

  // See if a room already exists
  room = await client.video.rooms(stream_name).fetch().catch(createErrorHandler('error finding room'));

  // Fetch stream map item
  streamMapItem = await getStreamMapItem(room.sid).catch(createErrorHandler('error finding stream map item'));

  const streamSyncClient = client.sync.services(streamMapItem.data.sync_service_sid);

  // Give user read access to stream document
  await streamSyncClient
    .documents('stream')
    .documentPermissions(user_identity)
    .update({ read: true, write: false, manage: false })
    .catch(createErrorHandler('error adding read access to stream document.'));

  const userDocumentName = `user-${user_identity}`;
  // Create user document
  userDocument = await streamSyncClient.documents
    .create({
      uniqueName: userDocumentName,
    })
    .catch((error) => {
      // Ignore "Unique name already exists" error
      if (error.code !== 54301) {
        createErrorHandler('error creating user document');
      }
    });

  // Update user document to set speaker_invite to false.
  // This is done outside of the user document creation to account
  // for users that may already have a user document
  await streamSyncClient
    .documents(userDocumentName)
    .update({
      data: { speaker_invite: false },
    })
    .catch(createErrorHandler('error updating user document'));

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

  const playbackGrant = await getPlaybackGrant(streamMapItem.data.player_streamer_sid).catch(
    createErrorHandler('error getting playback grant')
  );

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
    room_sid: room.sid,
  });

  callback(null, response);
};
