/* global Twilio Runtime */
'use strict';
const querystring = require('querystring');

const AccessToken = Twilio.jwt.AccessToken;
const VideoGrant = AccessToken.VideoGrant;
const ChatGrant = AccessToken.ChatGrant;
const SyncGrant = AccessToken.SyncGrant;
const MAX_ALLOWED_SESSION_DURATION = 14400;

module.exports.handler = async (context, event, callback) => {
  const { ACCOUNT_SID, TWILIO_API_KEY_SID, TWILIO_API_KEY_SECRET, CONVERSATIONS_SERVICE_SID, SYNC_SERVICE_SID } =
    context;

  const common = require(Runtime.getAssets()['/common.js'].path);
  const { axiosClient } = common(context, event, callback);

  const { user_identity, event_name } = event;

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

  if (!event_name) {
    response.setStatusCode(400);
    response.setBody({
      error: {
        message: 'missing event_name',
        explanation: 'The event_name parameter is missing.',
      },
    });
    return callback(null, response);
  }

  let room, playerStreamer, mediaProcessor, streamDocument, conversation, raisedHandsMap;

  const client = context.getTwilioClient();
  const syncClient = client.sync.services(context.SYNC_SERVICE_SID);

  try {
    room = await client.video.rooms.create({
      uniqueName: event_name,
      type: 'group',
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

  // Create stream document
  try {
    streamDocument = await syncClient.documents.create({
      uniqueName: `stream-${room.sid}`,
      data: {
        playerStreamerSid: playerStreamer.data.sid,
        mediaProcessorSid: mediaProcessor.data.sid,
      },
    });
  } catch (e) {
    console.error(e);
    response.setStatusCode(500);
    response.setBody({
      error: {
        message: 'error creating stream document',
        explanation: e.message,
      },
    });
    return callback(null, response);
  }

  // Create raised hands map
  try {
    raisedHandsMap = await syncClient.syncMaps.create({
      uniqueName: `raised_hands-${room.sid}`,
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
  const videoGrant = new VideoGrant({ room: event_name });
  token.addGrant(videoGrant);

  // Add chat grant to token
  const chatGrant = new ChatGrant({ serviceSid: CONVERSATIONS_SERVICE_SID });
  token.addGrant(chatGrant);

  // Add sync grant to token
  const syncGrant = new SyncGrant({ serviceSid: SYNC_SERVICE_SID });
  token.addGrant(syncGrant);

  // Return token
  response.setStatusCode(200);
  response.setBody({
    token: token.toJwt(),
    sync_object_names: {
      raised_hands_map: `raised_hands-${room.sid}`,
    },
  });
  return callback(null, response);
};
