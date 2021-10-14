/* global Twilio Runtime */
'use strict';
const querystring = require('querystring');

const AccessToken = Twilio.jwt.AccessToken;
const VideoGrant = AccessToken.VideoGrant;
const ChatGrant = AccessToken.ChatGrant;
const MAX_ALLOWED_SESSION_DURATION = 14400;

module.exports.handler = async (context, event, callback) => {
  const { ACCOUNT_SID, TWILIO_API_KEY_SID, TWILIO_API_KEY_SECRET, ROOM_TYPE, CONVERSATIONS_SERVICE_SID, DOMAIN_NAME } =
    context;

  const common = require(Runtime.getAssets()['/common.js'].path);
  const { axiosClient } = common(context, event, callback);

  const { user_identity, room_name, create_room = true, create_conversation = false } = event;

  let response = new Twilio.Response();
  response.appendHeader('Content-Type', 'application/json');

  if (typeof create_room !== 'boolean') {
    response.setStatusCode(400);
    response.setBody({
      error: {
        message: 'invalid parameter',
        explanation: 'A boolean value must be provided for the create_room parameter',
      },
    });
    return callback(null, response);
  }

  if (typeof create_conversation !== 'boolean') {
    response.setStatusCode(400);
    response.setBody({
      error: {
        message: 'invalid parameter',
        explanation: 'A boolean value must be provided for the create_conversation parameter',
      },
    });
    return callback(null, response);
  }

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

  if (!room_name && create_room) {
    response.setStatusCode(400);
    response.setBody({
      error: {
        message: 'missing room_name',
        explanation: 'The room_name parameter is missing. room_name is required when create_room is true.',
      },
    });
    return callback(null, response);
  }

  let room, playerStreamer, mediaProcessor, streamDocument, conversation;
  let roomCreated = false;

  if (create_room) {
    const client = context.getTwilioClient();
    const syncClient = client.sync.services(context.SYNC_SERVICE_SID);

    try {
      // See if a room already exists
      room = await client.video.rooms(room_name).fetch();
    } catch (e) {
      try {
        // If room doesn't exist, create it
        room = await client.video.rooms.create({
          uniqueName: room_name,
          type: ROOM_TYPE,
          statusCallback: 'https://' + DOMAIN_NAME + '/delete-stream',
        });

        roomCreated = true;
      } catch (e) {
        response.setStatusCode(500);
        response.setBody({
          error: {
            message: 'error creating room',
            explanation: 'Something went wrong when creating a room.',
          },
        });
        return callback(null, response);
      }
    }

    // If we created a room in the previous step, then we should create a new stream as well.
    if (roomCreated) {
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
            playbackGrant: null,
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
    }

    if (create_conversation) {
      const conversationsClient = client.conversations.services(CONVERSATIONS_SERVICE_SID);

      try {
        // See if conversation already exists
        conversation = await conversationsClient.conversations(room.sid).fetch();
      } catch (e) {
        try {
          // If conversation doesn't exist, create it.
          // Here we add a timer to close the conversation after the maximum length of a room (24 hours).
          // This helps to clean up old conversations since there is a limit that a single participant
          // can not be added to more than 1,000 open conversations.
          conversation = await conversationsClient.conversations.create({
            uniqueName: room.sid,
            'timers.closed': 'P1D',
          });
        } catch (e) {
          response.setStatusCode(500);
          response.setBody({
            error: {
              message: 'error creating conversation',
              explanation: 'Something went wrong when creating a conversation.',
            },
          });
          return callback(null, response);
        }
      }

      try {
        // Add participant to conversation
        await conversationsClient.conversations(room.sid).participants.create({ identity: user_identity });
      } catch (e) {
        // Ignore "Participant already exists" error (50433)
        if (e.code !== 50433) {
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
    }
  }

  // Create token
  const token = new AccessToken(ACCOUNT_SID, TWILIO_API_KEY_SID, TWILIO_API_KEY_SECRET, {
    ttl: MAX_ALLOWED_SESSION_DURATION,
  });

  // Add participant's identity to token
  token.identity = user_identity;

  // Add video grant to token
  const videoGrant = new VideoGrant({ room: room_name });
  token.addGrant(videoGrant);

  // Add chat grant to token
  const chatGrant = new ChatGrant({ serviceSid: CONVERSATIONS_SERVICE_SID });
  token.addGrant(chatGrant);

  // Return token
  response.setStatusCode(200);
  response.setBody({ token: token.toJwt(), room_type: ROOM_TYPE });
  return callback(null, response);
};
