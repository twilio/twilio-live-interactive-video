exports.handler = async function (context, event, callback) {
  const response = new Twilio.Response();

  // Set the status code to 204 Not Content
  response.setStatusCode(200);

  return callback(null, response);
};
