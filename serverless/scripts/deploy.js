const { TwilioServerlessApiClient } = require('@twilio-labs/serverless-api');
const { getListOfFunctionsAndAssets } = require('@twilio-labs/serverless-api/dist/utils/fs');
const cli = require('cli-ux').default;
const { Command } = require('commander');
const constants = require('../constants');
const { customAlphabet } = require('nanoid');
const viewApp = require(`${__dirname}/list.js`);

function getRandomInt(length) {
  return customAlphabet('1234567890', length)();
}

require('dotenv').config();

const program = new Command();
program.option('-o, --override', 'Override existing deployment');
program.parse(process.argv);
const options = program.opts();

const { ACCOUNT_SID, AUTH_TOKEN, TWILIO_ENVIRONMENT } = process.env;
const client = require('twilio')(ACCOUNT_SID, AUTH_TOKEN, {
  region: TWILIO_ENVIRONMENT || undefined,
});
const serverlessClient = new TwilioServerlessApiClient({
  username: ACCOUNT_SID,
  password: AUTH_TOKEN,
  region: TWILIO_ENVIRONMENT || undefined,
});

// Returns an object of the previously deployed environment variables if they exist.
async function findExistingConfiguration() {
  const services = await client.serverless.services.list();
  const service = services.find((service) => service.friendlyName.includes(constants.SERVICE_NAME));

  if (service) {
    const envVariables = await serverlessClient.getEnvironmentVariables({
      serviceSid: service.sid,
      environment: 'dev',
      keys: [
        'TWILIO_API_KEY_SID',
        'TWILIO_API_KEY_SECRET',
        'CONVERSATIONS_SERVICE_SID',
        'BACKEND_STORAGE_SYNC_SERVICE_SID',
      ],
      getValues: true,
    });

    const envVariablesObj = envVariables.variables.reduce(
      (prev, curr) => {
        prev[curr.key] = curr.value;
        return prev;
      },
      { serviceSid: service.sid }
    );

    return envVariablesObj;
  }
}

async function deployFunctions() {
  let apiKey, conversationsService, backendStorageSyncService, backendStorageSyncClient;
  const existingConfiguration = await findExistingConfiguration();

  if (!options.override && existingConfiguration) {
    console.log(
      'An app is already deployed. Please run "npm run serverless:deploy -- --override" to override the previous deployment.\n'
    );
    return;
  }

  // Create new services if they don't already exist
  if (!existingConfiguration) {
    cli.action.start('Creating Api Key');
    apiKey = await client.newKeys.create({
      friendlyName: constants.API_KEY_NAME,
    });

    cli.action.start('Creating Conversations Service');
    conversationsService = await client.conversations.services.create({
      friendlyName: constants.TWILIO_CONVERSATIONS_SERVICE_NAME,
    });

    cli.action.start('Creating Backend Storage Sync Service');
    backendStorageSyncService = await client.sync.services.create({
      friendlyName: constants.BACKEND_STORAGE_SYNC_SERVICE_NAME,
      aclEnabled: true,
    });
    backendStorageSyncClient = await client.sync.services(backendStorageSyncService.sid);
    await backendStorageSyncClient.syncMaps.create({ uniqueName: 'streams' });
  }

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
    // Create root asset
    assets.push({
      ...indexHTML,
      path: '/',
      name: '/',
    });
  }

  const deployConfig = {
    env: {
      TWILIO_API_KEY_SID: existingConfiguration?.TWILIO_API_KEY_SID || apiKey.sid,
      TWILIO_API_KEY_SECRET: existingConfiguration?.TWILIO_API_KEY_SECRET || apiKey.secret,
      CONVERSATIONS_SERVICE_SID: existingConfiguration?.CONVERSATIONS_SERVICE_SID || conversationsService.sid,
      BACKEND_STORAGE_SYNC_SERVICE_SID:
        existingConfiguration?.BACKEND_STORAGE_SYNC_SERVICE_SID || backendStorageSyncService.sid,
      SYNC_SERVICE_NAME_PREFIX: constants.SYNC_SERVICE_NAME_PREFIX,
      MEDIA_EXTENSION: constants.MEDIA_EXTENSION,
      APP_EXPIRY: Date.now() + 1000 * 60 * 60 * 24 * 7, // One week
      PASSCODE: getRandomInt(6),
    },
    pkgJson: {
      dependencies: {
        axios: '^0.21.4',
        twilio: '^3.68.0', // This determines the version of the Twilio client returned by context.getTwilioClient()
        '@twilio/runtime-handler': '1.2.1',
      },
    },
    functionsEnv: 'dev',
    assets,
    functions,
    overrideExistingService: options.override,
  };

  if (TWILIO_ENVIRONMENT) {
    deployConfig.env.TWILIO_REGION = TWILIO_ENVIRONMENT;
  }

  if (existingConfiguration) {
    // Deploy to existing service if it exists
    deployConfig.serviceSid = existingConfiguration.serviceSid;
  } else {
    deployConfig.serviceName = `${constants.SERVICE_NAME}-${getRandomInt(4)}`;
  }

  const { domain, serviceSid } = await serverlessClient.deployProject(deployConfig);

  // Make functions editable in console
  await client.serverless.services(serviceSid).update({ includeCredentials: true, uiEditable: true });
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
