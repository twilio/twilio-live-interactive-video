'use strict';

exports.handler = async function (context, event, callback) {
  const common = require(Runtime.getAssets()['/common.js'].path);
  const { axiosClient, response } = common(context, event, callback);

  const client = context.getTwilioClient();
  const syncClient = client.sync.services(context.SYNC_SERVICE_SID);

  const { StatusCallbackEvent, RoomSid } = event;

  if (StatusCallbackEvent === 'room-ended') {
    try {
      // Get playerStreamerSid and mediaProcessorSid from stream document
      const streamDocument = await syncClient.documents(`stream-${RoomSid}`).fetch();
      const { playerStreamerSid, mediaProcessorSid } = streamDocument.data;

      // Stop mediaProcessor
      await axiosClient(`MediaProcessors/${mediaProcessorSid}`, {
        method: 'post',
        data: 'Status=ENDED',
      });

      // Stop playerStreamer
      await axiosClient(`PlayerStreamers/${playerStreamerSid}`, {
        method: 'post',
        data: 'Status=ENDED',
      });

      // delete stream document
      await syncClient.documents(`stream-${RoomSid}`).remove();

      console.log('deleted: ', RoomSid);
    } catch (e) {
      console.log(e);
      response.setStatusCode(500);
      response.setBody({
        error: {
          message: 'error deleting stream',
          explanation: e.message,
        },
      });
      return callback(null, response);
    }
  }

  response.setBody({
    deleted: true,
  });

  callback(null, response);
};
