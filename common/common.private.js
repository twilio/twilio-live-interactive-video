'use strict';

const axios = require('axios');

module.exports = (context, event, callback) => {
  let response = new Twilio.Response();
  response.appendHeader('Content-Type', 'application/json');

  const {region} = context.getTwilioClient();

  const axiosClient = axios.create({
    headers: {
      Authorization: 'Basic ' + Buffer.from(`${context.ACCOUNT_SID}:${context.AUTH_TOKEN}`, 'utf8').toString('base64'),
      'content-type': 'application/x-www-form-urlencoded;charset=utf-8',
    },
    baseURL: (region === 'dev' || region === 'stage')
      ? `https://media.${region}.twilio.com/v1`
      : 'https://media.twilio.com/v1',
  });

  async function getPlaybackGrant(livePlayerStreamerSid) {
    const playbackGrant = await axiosClient(`PlayerStreamers/${livePlayerStreamerSid}/PlaybackGrant`, {
      method: 'post',
      data: `AccessControlAllowOrigin=*`,
    });
    return playbackGrant.data.grant;
  }

  return {
    axiosClient,
    response,
    getPlaybackGrant,
  };
};
