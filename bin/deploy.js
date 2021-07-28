#!/usr/bin/env node

const fse = require('fs-extra');
const appAssetsDir = 'assets' 
const appBuildDir = 'apps/web/build' 
const promisify = require('util').promisify;
const exec = promisify(require('child_process').exec);

(async () => {
  try {
    /**
     * Build the app projects
     */
    await exec('npm --prefix composer run build');
    await exec('npm --prefix apps/web run build');

    /**
     * Copy the build outputs to the assets directory for twilio-run to deploy
    */
    if (fse.existsSync(appAssetsDir)) {
      fse.removeSync(appAssetsDir);
    }
    fse.mkdirSync(appAssetsDir);
    fse.copySync(appBuildDir, appAssetsDir);

    /**
     * Deploy the builds and extract user output from the twilio-run command
     */
    const { stdout } = await exec('twilio-run deploy --override-existing-project');
    const twilioRunOutputRegex = RegExp('domain\\s+(?<domain>.*)', 'm');
    const match = stdout.match(twilioRunOutputRegex);
    if (match.groups?.domain) {
      const appUrl = `https://${match.groups.domain.trim()}/index.html`;
      console.log(`App: ${appUrl}`);
    } else {
      throw Error('Failed to extract app url');
    }
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
})()