exports.handler = async function (context, event, callback) {
  let response = new Twilio.Response();
  response.appendHeader('Content-Type', 'application/json');

  const client = context.getTwilioClient();

  try {
    await client.video.rooms(event.room_name).participants(event.user_identity).update({ status: 'disconnected' })
  } catch (e) {
    console.error(e);
    response.setStatusCode(500);
    response.setBody({
      error: {
        message: 'error removing speaker',
        explanation: e.message,
      }
    });
    return callback(null, response);
  }

  response.setBody({
    removed: true,
  });

  callback(null, response);
};
