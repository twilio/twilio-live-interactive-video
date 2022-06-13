/* global Twilio Runtime */
'use strict';
const querystring = require('querystring');

const AccessToken = Twilio.jwt.AccessToken;
const VideoGrant = AccessToken.VideoGrant;
const ChatGrant = AccessToken.ChatGrant;
const SyncGrant = AccessToken.SyncGrant;
const MAX_ALLOWED_SESSION_DURATION = 14400;

module.exports.handler = async (context, event, callback) => {
  const {
    ACCOUNT_SID,
    TWILIO_API_KEY_SID,
    TWILIO_API_KEY_SECRET,
    CONVERSATIONS_SERVICE_SID,
    BACKEND_STORAGE_SYNC_SERVICE_SID,
    SYNC_SERVICE_NAME_PREFIX,
    DOMAIN_NAME,
  } = context;

  const authHandler = require(Runtime.getAssets()['/auth.js'].path);
  authHandler(context, event, callback);

  const common = require(Runtime.getAssets()['/common.js'].path);
  const { axiosClient, createErrorHandler } = common(context, event, callback);

  const { user_identity, stream_name, record_stream = false } = event;

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

  let room, playerStreamer, mediaProcessor, streamSyncService, streamSyncClient, conversation;

  const client = context.getTwilioClient();

  room = await client.video.rooms
    .create({
      uniqueName: stream_name,
      type: 'group',
      statusCallback: 'https://' + DOMAIN_NAME + '/rooms-webhook',
    })
    .catch(createErrorHandler('error creating room.'));

  // Create stream sync service
  streamSyncService = await client.sync.services
    .create({
      friendlyName: SYNC_SERVICE_NAME_PREFIX + 'Stream ' + room.sid,
      aclEnabled: true,
      webhookUrl: 'https://' + DOMAIN_NAME + '/sync-webhook',
      reachabilityWebhooksEnabled: true,
      reachabilityDebouncingEnabled: true, // To prevent disconnect event when connections are rebalanced
    })
    .catch(createErrorHandler('error creating stream sync service.'));

  streamSyncClient = client.sync.services(streamSyncService.sid);

  // Create stream document
  await streamSyncClient.documents
    .create({
      uniqueName: 'stream',
      data: {
        recording: {
          is_recording: record_stream,
          error: null,
        },
      },
    })
    .catch(createErrorHandler('error creating stream document.'));

  // Give user read access to stream document
  await streamSyncClient
    .documents('stream')
    .documentPermissions(user_identity)
    .update({ read: true, write: false, manage: false })
    .catch(createErrorHandler('error adding read access to stream document.'));

  // Create playerStreamer
  playerStreamer = await axiosClient('PlayerStreamers', {
    method: 'post',
    data: 'Video=true',
  }).catch(createErrorHandler('error creating PlayerStreamer.'));

  // Create mediaProcessor
  mediaProcessor = await axiosClient('MediaProcessors', {
    method: 'post',
    data: querystring.stringify({
      MaxDuration: 60 * 30, // Set maxDuration to 30 minutes
      Extension: context.MEDIA_EXTENSION,
      ExtensionContext: JSON.stringify({
        room: { name: room.sid },
        outputs: [playerStreamer.data.sid],
        resolution: '1920x1080',
        ...record_stream && {
          recordings: [
            {
              containerFormat: "mp4",
              hostedByTwilio: true
            }
          ]
        }
      }),
    }),
  }).catch(createErrorHandler('error creating MediaProcessor.'));

  console.log(
    'created stream: ',
    JSON.stringify({
      stream_url: playerStreamer.data.playback_url,
      playerStreamerSid: playerStreamer.data.sid,
      mediaProcessorSid: mediaProcessor.data.sid,
    })
  );

  // Add stream to streams map
  const backendStorageSyncService = client.sync.services(BACKEND_STORAGE_SYNC_SERVICE_SID);
  await backendStorageSyncService
    .syncMaps('streams')
    .syncMapItems.create({
      key: room.sid,
      data: {
        sync_service_sid: streamSyncService.sid,
        player_streamer_sid: playerStreamer.data.sid,
        media_processor_sid: mediaProcessor.data.sid,
      },
    })
    .catch(createErrorHandler('error adding stream to streams map.'));

  // Create speakers map
  await streamSyncClient.syncMaps
    .create({
      uniqueName: 'speakers',
    })
    .catch(createErrorHandler('error creating speakers map.'));

  // Add the host to the speakers map when the stream is created so that:
  //
  //   1. The speakers map is guaranteed to contain the host before any user connects to the stream.
  //   2. We don't need a separate way to keep track of who the host is.
  //
  // There is only one host and it is the user that creates the stream. Other users are added to
  // the speakers map in rooms-webhook when they connect to the video room.

  await streamSyncClient
    .syncMaps('speakers')
    .syncMapItems.create({
      key: user_identity,
      data: { host: true },
    })
    .catch(createErrorHandler('error adding host to speakers map.'));

  // Give user read access to speakers map
  await streamSyncClient
    .syncMaps('speakers')
    .syncMapPermissions(user_identity)
    .update({ read: true, write: false, manage: false })
    .catch(createErrorHandler('error adding read access to speakers map.'));

  // Create raised hands map
  await streamSyncClient.syncMaps
    .create({
      uniqueName: 'raised_hands',
    })
    .catch(createErrorHandler('error creating raised hands map.'));

  // Give user read access to raised hands map
  await streamSyncClient
    .syncMaps('raised_hands')
    .syncMapPermissions(user_identity)
    .update({ read: true, write: false, manage: false })
    .catch(createErrorHandler('error adding read access to raised hands map.'));

  // Create viewers map
  await streamSyncClient.syncMaps
    .create({
      uniqueName: 'viewers',
    })
    .catch(createErrorHandler('error creating viewers map.'));

  // Give user read access to viewers map
  await streamSyncClient
    .syncMaps('viewers')
    .syncMapPermissions(user_identity)
    .update({ read: true, write: false, manage: false })
    .catch(createErrorHandler('error adding read access to viewers map.'));

  const conversationsClient = client.conversations.services(CONVERSATIONS_SERVICE_SID);

  // Here we add a timer to close the conversation after the maximum length of a room (24 hours).
  // This helps to clean up old conversations since there is a limit that a single participant
  // can not be added to more than 1,000 open conversations.
  conversation = await conversationsClient.conversations
    .create({
      uniqueName: room.sid,
      'timers.closed': 'P1D',
    })
    .catch(createErrorHandler('error creating conversation.'));

  // Add participant to conversation
  await conversationsClient
    .conversations(room.sid)
    .participants.create({ identity: user_identity })
    .catch((error) => {
      // Ignore "Participant already exists" error (50433)
      if (error.code !== 50433) {
        createErrorHandler('error creating stream sync service.')(error);
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
  const syncGrant = new SyncGrant({ serviceSid: streamSyncService.sid });
  token.addGrant(syncGrant);

  // Return token
  response.setStatusCode(200);
  response.setBody({
    token: token.toJwt(),
  });
  return callback(null, response);
};
