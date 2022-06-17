require('dotenv').config();
const client = require('twilio')(process.env.ACCOUNT_SID, process.env.AUTH_TOKEN);
const axios = require('axios');
const axiosClient = axios.create({
  headers: {
    Authorization:
      'Basic ' + Buffer.from(`${process.env.ACCOUNT_SID}:${process.env.AUTH_TOKEN}`, 'utf8').toString('base64'),
    'content-type': 'application/x-www-form-urlencoded;charset=utf-8',
  },
  baseURL:
    client.region === 'dev' || client.region === 'stage'
      ? `https://media.${region}.twilio.com/v1`
      : 'https://media.twilio.com/v1',
});

(async function () {
  const recordings = (await axiosClient('MediaRecordings')).data.media_recordings;
  const rooms = await client.video.rooms.list({ status: 'completed', limit: 100 });

  console.log('\nAvailable Twilio Live Recordings');
  console.log('--------------------------------\n');

  recordings.forEach((recording) => {
    const recordingUrl = recording.links.media;
    const room = rooms.find((room) => room.sid === recording.source_sid);

    console.log(`Event Name: ${room.uniqueName} | Recording URL: ${recordingUrl}`);
  });

  console.log(
    '\nPlease remember to use your Twilio Account SID and Auth Token when accessing the recording URLs in the browser.\n'
  );
})();
