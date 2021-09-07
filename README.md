# Twilio Live Interactive Video 

This project demonstrates an interactive live video streaming app that uses [Twilio Live](https://www.twilio.com/docs/live) and [Twilio Video](https://www.twilio.com/docs/video). The project is setup as a monorepo that contains the frontend reference applications for the Web and iOS (Android coming soon). 

## Features

* Deploy the application to Twilio Serverless in just a few minutes.
* Create or join a stream as a speaker and collaborate with other users.
* Join a stream as a viewer to see the Twilio Video Room participants composed as a high quality media stream.

## Getting Started 

This section describes the steps required for all developers to get started with their respective platform.

### Requirements

* [Node.js v14+](https://nodejs.org/en/download/)
* NPM v6+ (comes installed with newer Node versions)

### Setup Enviromenment

Copy the `.env.example` file to `.env` and perform the following one-time steps before deploying your application. 

#### Set your Account Sid and Auth Token

Update the ACCOUNT_SID and AUTH_TOKEN `.env` entries with the Account SID and Auth Token found on the [Twilio Console home page](https://twilio.com/console).

#### Set your API Key and API Key Secret 

Create an API Key and Secret and update the TWILIO_API_KEY_SID and TWILIO_API_KEY_SECRET `.env` entries. You can create a new API Key and Secret in the Twilio Console by navigating to `Account -> API Keys`.

#### Provide a Twilio Sync Service SID 

Update the SYNC_SERVICE_SID `.env` entry with your Default Service SID found in `Sync -> Services` or use a new Twilio Sync Service SID that can be created in the Twilio console.

#### Install Dependencies

Once you have setup all your environment variables, run `npm install` to install all dependencies from NPM.

### Deploy the app to Twilio

Once the application environment has been configured and dependencies have been installed, you can deploy the app backend and web app using the following command.

```shell
npm run deploy

App: https://twilio-live-interactive-video-7873-dev.twil.io
```

If you make any changes to the application, then you can run `npm run deploy` again and subsequent deploys will override your existing app.
