exports.handler = async function (context, event, callback) {
  const response = new Twilio.Response();

  response.setStatusCode(200);

  return callback(null, response);
};
