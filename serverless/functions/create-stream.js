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

  const common = require(Runtime.getAssets()['/common.js'].path);
  const { axiosClient } = common(context, event, callback);

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

  let room, playerStreamer, mediaProcessor, streamSyncService, streamSyncClient, conversation;

  const client = context.getTwilioClient();

  try {
    room = await client.video.rooms.create({
      uniqueName: stream_name,
      type: 'group',
      statusCallback: 'https://' + DOMAIN_NAME + '/rooms-webhook',
    });
  } catch (e) {
    console.error(e);
    response.setStatusCode(500);
    response.setBody({
      error: {
        message: 'error creating room',
        explanation: e.message,
      },
    });
    return callback(null, response);
  }

  try {
    // Create playerStreamer
    playerStreamer = await axiosClient('PlayerStreamers', {
      method: 'post',
      data: 'Video=true',
    });

    // Create mediaProcessor
    mediaProcessor = await axiosClient('MediaProcessors', {
      method: 'post',
      data: querystring.stringify({
        Extension: context.MEDIA_EXTENSION,
        ExtensionContext: JSON.stringify({
          room: { name: room.sid },
          outputs: [playerStreamer.data.sid],
        }),
      }),
    });

    console.log(
      'created stream: ',
      JSON.stringify({
        stream_url: playerStreamer.data.playback_url,
        playerStreamerSid: playerStreamer.data.sid,
        mediaProcessorSid: mediaProcessor.data.sid,
      })
    );
  } catch (e) {
    console.error(e);
    response.setStatusCode(500);
    response.setBody({
      error: {
        message: 'error creating stream',
        explanation: e.message,
      },
    });

    return callback(null, response);
  }

  // Create stream sync service
  try {
    streamSyncService = await client.sync.services.create({ 
      friendlyName: SYNC_SERVICE_NAME_PREFIX + 'Stream ' + room.sid, 
      aclEnabled: true,
      webhookUrl: 'https://' + DOMAIN_NAME + '/sync-webhook',
      reachabilityWebhooksEnabled: true,
      reachabilityDebouncingEnabled: true // To prevent disconnect event when connections are rebalanced
    });
    streamSyncClient = await client.sync.services(streamSyncService.sid);
  } catch (e) {
    console.error(e);
    response.setStatusCode(500);
    response.setBody({
      error: {
        message: 'error creating stream sync service',
        explanation: e.message,
      },
    });
    return callback(null, response);
  }

  // Add stream to streams map
  try {
    const backendStorageSyncService = client.sync.services(BACKEND_STORAGE_SYNC_SERVICE_SID);

    await backendStorageSyncService.syncMaps('streams').syncMapItems.create({ 
      key: room.sid, 
      data: {
        sync_service_sid: streamSyncService.sid,
        player_streamer_sid: playerStreamer.data.sid,
        media_processor_sid: mediaProcessor.data.sid
      } 
    });
  } catch (e) {
    console.error(e);
    response.setStatusCode(500);
    response.setBody({
      error: {
        message: 'error adding stream to streams map',
        explanation: e.message,
      },
    });
    return callback(null, response);
  }

  const raisedHandsMapName = `raised_hands`
  // Create raised hands map
  try {
    await streamSyncClient.syncMaps.create({
      uniqueName: raisedHandsMapName
    });
  } catch (e) {
    console.error(e);
    response.setStatusCode(500);
    response.setBody({
      error: {
        message: 'error creating raised hands map',
        explanation: e.message,
      },
    });
    return callback(null, response);
  }

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

  const viewersMapName = `viewers`
  
  // Create viewers map
  try {
    await streamSyncClient.syncMaps.create({
      uniqueName: viewersMapName
    });
  } catch (e) {
    console.error(e);
    response.setStatusCode(500);
    response.setBody({
      error: {
        message: 'error creating viewers map',
        explanation: e.message,
      },
    });
    return callback(null, response);
  }

  // Give user read access to viewers map
  try {
    await streamSyncClient.syncMaps(viewersMapName)
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
    // Here we add a timer to close the conversation after the maximum length of a room (24 hours).
    // This helps to clean up old conversations since there is a limit that a single participant
    // can not be added to more than 1,000 open conversations.
    conversation = await conversationsClient.conversations.create({
      uniqueName: room.sid,
      'timers.closed': 'P1D',
    });
  } catch (e) {
    console.error(e);
    response.setStatusCode(500);
    response.setBody({
      error: {
        message: 'error creating conversation',
        explanation: 'Something went wrong when creating a conversation.',
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
  const syncGrant = new SyncGrant({ serviceSid: streamSyncService.sid });
  token.addGrant(syncGrant);

  // Return token
  response.setStatusCode(200);
  response.setBody({
    token: token.toJwt(),
    sync_object_names: {
      viewers_map: 'viewers',
      raised_hands_map: `raised_hands`,
    },
  });
  return callback(null, response);
};
