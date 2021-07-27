#!/usr/bin/env node

const fse = require('fs-extra');
const appAssetsDir = 'assets' 
const appBuildDir = 'apps/web/build' 
const exec = require('child_process').exec;

new Promise((resolve, reject) => {
  exec('npm --prefix composer run build', error => error ? reject(error) : resolve())
}).then(() => {
  new Promise((resolve, reject) => {
    exec('npm --prefix apps/web run build', error => error ? reject(error) : resolve())
  })
}).then(() => {
  /**
   * Copy the build outputs to the assets directory for twilio-run to deploy
   */
  new Promise((_) => {
    if (fse.existsSync(appAssetsDir)) {
      fse.removeSync(appAssetsDir)
    }
    fse.mkdirSync(appAssetsDir)
    fse.copySync(appBuildDir, appAssetsDir)
  })
}).then(() => {
  new Promise((resolve, reject) => {
    exec('twilio-run deploy --override-existing-project', (error, stdout, stderr) => {
      if (error) {
        reject(error)
      } else {
        const twilioRunOutputRegex = RegExp('domain\\s+(?<domain>.*)', 'm')
        const match = stdout.match(twilioRunOutputRegex)
        if (match.groups.domain) {
          const appUrl = `https://${match.groups.domain}/index.html`
          console.log(`App: ${appUrl}`)
          resolve()
        } else {
          reject(Error('Failed to extract app url'))
        }
      }
    })
  })
}).catch(error => {
  console.error(error);
  process.exit(1);
});