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

const client = require('twilio')(process.env.ACCOUNT_SID, process.env.AUTH_TOKEN);
const serverlessClient = new TwilioServerlessApiClient({
  username: process.env.ACCOUNT_SID,
  password: process.env.AUTH_TOKEN,
});

// Returns an object of the previously deployed environment variables if they exist.
async function findExistingConfiguration() {
  const services = await client.serverless.services.list();
  const service = services.find((service) => service.friendlyName.includes(constants.SERVICE_NAME));

  if (service) {
    const envVariables = await serverlessClient.getEnvironmentVariables({
      serviceSid: service.sid,
      environment: 'dev',
      keys: ['TWILIO_API_KEY_SID', 'TWILIO_API_KEY_SECRET', 'CONVERSATIONS_SERVICE_SID', 'SYNC_SERVICE_SID'],
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
  let apiKey, conversationsService, syncService;
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
    apiKey = await client.newKeys.create({ friendlyName: constants.API_KEY_NAME });

    cli.action.start('Creating Conversations Service');
    conversationsService = await client.conversations.services.create({
      friendlyName: constants.TWILIO_CONVERSATIONS_SERVICE_NAME,
    });

    cli.action.start('Creating Sync Service');
    syncService = await client.sync.services.create({ friendlyName: constants.TWILIO_SYNC_SERVICE_NAME });
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
      SYNC_SERVICE_SID: existingConfiguration?.SYNC_SERVICE_SID || syncService.sid,
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
    overrideExistingService: options.override,
  };

  if (existingConfiguration) {
    // Deploy to existing service if it exists
    deployConfig.serviceSid = existingConfiguration.serviceSid;
  } else {
    deployConfig.serviceName = `${constants.SERVICE_NAME}-${getRandomInt(4)}`;
  }

  return serverlessClient.deployProject(deployConfig);
}

async function deploy() {
  await deployFunctions();
  cli.action.stop();
  console.log('\n');
  await viewApp();
}

if (require.main === module) {
  deploy();
} else {
  module.exports = deploy;
}
