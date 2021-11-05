/* global Twilio Runtime */
'use strict';

const AccessToken = Twilio.jwt.AccessToken;

module.exports.handler = async (context, event, callback) => {
//   const { ACCOUNT_SID, TWILIO_API_KEY_SID, TWILIO_API_KEY_SECRET } = context;

  const authHandler = require(Runtime.getAssets()['/auth-handler.js'].path);
  authHandler(context, event, callback);


  let response = new Twilio.Response();
  response.appendHeader('Content-Type', 'application/json');

  // Create token
  const token = new AccessToken(ACCOUNT_SID, TWILIO_API_KEY_SID, TWILIO_API_KEY_SECRET);

  // Return token
  response.setStatusCode(200);
//   response.setBody({ token: token.toJwt() });
  return callback(null, response);
};