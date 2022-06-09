'use strict';

exports.handler = async function (context, event, callback) {
  const authHandler = require(Runtime.getAssets()['/auth.js'].path);
  authHandler(context, event, callback);

  const common = require(Runtime.getAssets()['/common.js'].path);
  const { response, createErrorHandler } = common(context, event, callback);

  const client = context.getTwilioClient();

  const { stream_name } = event;

  // End the video room which will cause everything else to be cleaned up in the rooms webhook
  await client.video
    .rooms(stream_name)
    .update({ status: 'completed' })
    .catch(createErrorHandler('error deleting stream'));

  console.log('deleted: ', stream_name);

  response.setBody({
    deleted: true,
  });

  callback(null, response);
};
