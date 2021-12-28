/* global Twilio Runtime */
'use strict';

// verifies that auth.js does not throw error for passcode:

module.exports.handler = async (context, event, callback) => {
  const authHandler = require(Runtime.getAssets()['/auth.js'].path);
  authHandler(context, event, callback);

  let response = new Twilio.Response();
  response.appendHeader('Content-Type', 'application/json');

  response.setStatusCode(200);

  response.setBody({ verified: true });

  return callback(null, response);
};
