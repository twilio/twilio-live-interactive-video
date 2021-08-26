'use strict';

exports.handler = async function (context, event, callback) {
  const common = require(Runtime.getAssets()['/common.js'].path);
  const { axiosClient, response } = common(context, event, callback);

  const client = context.getTwilioClient();
  const syncClient = client.sync.services(context.SYNC_SERVICE_SID);

  const { StatusCallbackEvent, RoomSid } = event;

  if (StatusCallbackEvent === 'room-ended') {
    try {
      // Get livePlayerStreamerSid and mediaComposerSid from stream document
      const streamDocument = await syncClient.documents(`stream-${RoomSid}`).fetch();
      const { livePlayerStreamerSid, mediaComposerSid } = streamDocument.data;

      // Stop mediaComposer
      await axiosClient(`MediaComposers/${mediaComposerSid}`, {
        method: 'post',
        data: 'Status=ENDED',
      });

      // Stop livePlayerStreamer
      await axiosClient(`PlayerStreamers/${livePlayerStreamerSid}`, {
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
