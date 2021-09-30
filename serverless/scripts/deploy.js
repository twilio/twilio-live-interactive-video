const { TwilioServerlessApiClient } = require('@twilio-labs/serverless-api');
const { getListOfFunctionsAndAssets } = require('@twilio-labs/serverless-api/dist/utils/fs');
const { getService } = require('@twilio-labs/serverless-api/dist/api/services');
const cli = require('cli-ux').default;
const constants = require('../constants');
const { customAlphabet } = require('nanoid');
const viewApp = require(`${__dirname}/list.js`);

function getRandomInt(length) {
  return customAlphabet('1234567890', length)();
}

require('dotenv').config();

const client = require('twilio')(process.env.ACCOUNT_SID, process.env.AUTH_TOKEN);
const serverlessClient = new TwilioServerlessApiClient({
  username: process.env.ACCOUNT_SID,
  password: process.env.AUTH_TOKEN,
});

async function deployFunctions() {
  cli.action.start('Creating Api Key');
  const apiKey = await client.newKeys.create({ friendlyName: constants.API_KEY_NAME });

  cli.action.start('Creating Conversations Service');
  const conversationsService = await client.conversations.services.create({
    friendlyName: constants.TWILIO_CONVERSATIONS_SERVICE_NAME,
  });

  cli.action.start('Creating Sync Service');
  const syncService = await client.sync.services.create({ friendlyName: constants.TWILIO_SYNC_SERVICE_NAME });

  const { assets, functions } = await getListOfFunctionsAndAssets(__dirname, {
    functionsFolderNames: ['../functions'],
    assetsFolderNames: ['../../apps/web/build'],
  });

  serverlessClient.on('status-update', (evt) => {
    cli.action.start(evt.message);
  });

  // Calling 'getListOfFunctionsAndAssets' twice is necessary because it only gets the assets from
  // the first matching folder in the array
  const { assets: fnAssets } = await getListOfFunctionsAndAssets(__dirname, {
    assetsFolderNames: ['../middleware'],
  });

  assets.push(...fnAssets);

  const indexHTML = assets.find((asset) => asset.name.includes('index.html'));

  if (indexHTML) {
    assets.push({
      ...indexHTML,
      path: '/',
      name: '/',
    });
  }

  // serverlessClient
  return serverlessClient.deployProject({
    env: {
      TWILIO_API_KEY_SID: apiKey.sid,
      TWILIO_API_KEY_SECRET: apiKey.secret,
      CONVERSATIONS_SERVICE_SID: conversationsService.sid,
      SYNC_SERVICE_SID: syncService.sid,
      VIDEO_IDENTITY: constants.VIDEO_IDENTITY,
      MEDIA_EXTENSION: constants.MEDIA_EXTENSION,
      APP_EXPIRY: Date.now() + 1000 * 60 * 60 * 24 * 7, // One week
      PASSCODE: getRandomInt(6),
    },
    pkgJson: {
      dependencies: {
        axios: '^0.21.4',
        twilio: '^3.68.0', // This determines the version of the Twilio client returned by context.getTwilioClient()
      },
    },
    functionsEnv: 'dev',
    assets,
    functions,
    serviceName: `${constants.SERVICE_NAME}-${getRandomInt(4)}`,
    overrideExistingService: true,
  });
}

async function deploy() {
  await deployFunctions();

  cli.action.stop();
  await viewApp();
}

if (require.main === module) {
  deploy();
} else {
  module.exports = deploy;
}
