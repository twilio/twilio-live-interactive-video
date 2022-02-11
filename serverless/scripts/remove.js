require('dotenv').config();
const client = require('twilio')(process.env.ACCOUNT_SID, process.env.AUTH_TOKEN);
const cli = require('cli-ux').default;
const constants = require('../constants');

async function remove() {
  cli.action.start('Removing service');
  const services = await client.serverless.services.list();
  const app = services.find((service) => service.friendlyName.includes(constants.SERVICE_NAME));
  if (app) {
    await client.serverless.services(app.sid).remove();
  }

  cli.action.start('Removing Api Key');
  const keys = await client.keys.list();
  const app_key = keys.find((key) => key.friendlyName === constants.API_KEY_NAME);
  if (app_key) {
    client.keys(app_key.sid).remove();
  }

  cli.action.start('Removing Conversations Service');
  const conversationsServices = await client.conversations.services.list();
  const conversationsService = conversationsServices.find(
    (key) => key.friendlyName === constants.TWILIO_CONVERSATIONS_SERVICE_NAME
  );
  if (conversationsService) {
    client.conversations.services(conversationsService.sid).remove();
  }

  cli.action.start('Removing Sync Services');
  const syncServices = await client.sync.services.list();
  syncServices.forEach(async function(service) {
    if (service.friendlyName.includes(constants.SYNC_SERVICE_NAME_PREFIX)) {
      cli.action.start(`Removing Sync Service: ${service.friendlyName}`);
      const syncService = client.sync.services(service.sid);

      /**
       * The live interactive video app relies on webhooks to release Twilio Live backend resources. As a result, end all 
       * active PlayerStreamers and MediaProcessors when removing the app to prevent scenarios where a stream is active, but the 
       * application has been removed.
       */
      if (syncService.friendlyName === constants.BACKEND_STORAGE_SYNC_SERVICE_SID) {
        cli.action.start(`Ending active PlayerStreamers and MediaProcessors:`);
        await syncService
              .syncMaps('streams')
              .syncMapItems
              .each(async streamMapItem => {
                const { player_streamer_sid, media_processor_sid } = streamMapItem.data;

                cli.action.start(`Ending MediaProcessor: ${media_processor_sid}`)
                await client.media.mediaProcessor(media_processor_sid)
                  .update({status: 'ended'});
      
                cli.action.start(`Ending PlayerStreamer: ${player_streamer_sid}`)
                await client.media.playerStreamer(player_streamer_sid)
                  .update({status: 'ended'});
              });
      }

      syncService.remove();
    }
  })

  cli.action.stop();
}

if (require.main === module) {
  remove();
} else {
  module.exports = remove;
}
