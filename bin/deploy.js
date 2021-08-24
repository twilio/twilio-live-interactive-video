#!/usr/bin/env node

const { cli } = require('cli-ux');
const fse = require('fs-extra');
const appAssetsDir = 'assets';
const appBuildDir = 'apps/web/build';
const functionCommonFiles = 'common';
const promisify = require('util').promisify;
const exec = promisify(require('child_process').exec);

(async () => {
  try {
    /**
     * Build the app projects
     */
    cli.action.start('building web app');
    // await exec('npm --prefix composer run build');
    await exec('npm --prefix apps/web run build');

    /**
     * Copy the build outputs to the assets directory for twilio-run to deploy
     */
    cli.action.start('preparing assets for deployment');
    if (fse.existsSync(appAssetsDir)) {
      fse.removeSync(appAssetsDir);
    }
    fse.mkdirSync(appAssetsDir);
    fse.copySync(appBuildDir, appAssetsDir);

    // Add root asset for web app
    fse.mkdirSync(`${appAssetsDir}/assets`);
    fse.copySync(`${appBuildDir}/index.html`, `${appAssetsDir}/assets/index.html`);

    /**
     * Copy the functions common files to the assets directory for twilio-run to deploy
     */
    fse.copySync(functionCommonFiles, appAssetsDir);

    /**
     * Deploy the builds and extract user output from the twilio-run command
     */
    cli.action.start('deploying app and functions');
    const { stdout } = await exec('twilio-run deploy --override-existing-project');
    const twilioRunOutputRegex = RegExp('domain\\s+(?<domain>.*)', 'm');
    const match = stdout.match(twilioRunOutputRegex);
    if (match.groups && match.groups.domain) {
      const appUrl = `https://${match.groups.domain.trim()}/index.html`;
      cli.action.stop('done');
      console.log(`App: ${appUrl}`);
    } else {
      throw Error('Failed to extract app url');
    }
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
})();
