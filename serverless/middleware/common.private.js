'use strict';

const axios = require('axios');

module.exports = (context, event, callback) => {
  let response = new Twilio.Response();
  response.appendHeader('Content-Type', 'application/json');

  const client = context.getTwilioClient();
  const region = client.region;  

  const axiosClient = axios.create({
    headers: {
      Authorization: 'Basic ' + Buffer.from(`${context.ACCOUNT_SID}:${context.AUTH_TOKEN}`, 'utf8').toString('base64'),
      'content-type': 'application/x-www-form-urlencoded;charset=utf-8',
    },
    baseURL:
      region === 'dev' || region === 'stage' ? `https://media.${region}.twilio.com/v1` : 'https://media.twilio.com/v1',
  });

  async function getPlaybackGrant(playerStreamerSid) {
    const playbackGrant = await axiosClient(`PlayerStreamers/${playerStreamerSid}/PlaybackGrant`, {
      method: 'post',
      data: `AccessControlAllowOrigin=*`,
    });
    return playbackGrant.data.grant;
  }

  async function getStreamMapItem(roomSid) {
    const backendStorageSyncClient = await client.sync.services(context.BACKEND_STORAGE_SYNC_SERVICE_SID);
    const mapItem = await backendStorageSyncClient.syncMaps('streams').syncMapItems(roomSid).fetch();
    return mapItem;
  }

  return {
    axiosClient,
    response,
    getPlaybackGrant,
    getStreamMapItem
  };
};
