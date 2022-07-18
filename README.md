# Twilio Live Interactive Video

This project demonstrates an interactive live video streaming app that uses [Twilio Live](https://www.twilio.com/docs/live), [Twilio Video](https://www.twilio.com/docs/video), and [Twilio Sync](https://www.twilio.com/docs/sync). Check out [this blog post](https://www.twilio.com/blog/interactive-live-streaming-app-programmable-video-live-sync) for more details about the app's features and how it was built. The project is setup as a monorepo that contains the frontend reference applications for the Web and iOS (Android coming soon).

## Features

- Deploy the application to Twilio Serverless in just a few minutes.
- Create or join a stream as a speaker and collaborate with other users.
- Join a stream as a viewer to see the Twilio Video Room participants composed as a high quality media stream.

## Getting Started

This section describes the steps required for all developers to get started with their respective platform.

### Requirements

- [Node.js v14+](https://nodejs.org/en/download/)
- NPM v7+ (upgrade from NPM 6 with `npm install --global npm`)

### Setup Enviromenment

Copy the `.env.example` file to `.env` and perform the following one-time steps before deploying your application.

#### Set your Account Sid and Auth Token

Update the ACCOUNT_SID and AUTH_TOKEN `.env` entries with the Account SID and Auth Token found on the [Twilio Console home page](https://twilio.com/console).

**NOTE**: the use of Twilio Conversations is optional. If you wish to opt out, set the `DISABLE_CHAT` environment variable to `true`.

#### Install Dependencies

Once you have setup all your environment variables, run `npm install` to install all dependencies from NPM.

### Deploy the app to Twilio

Once the application environment has been configured and dependencies have been installed, you can deploy the app backend and web app using the following command.

```shell
npm run serverless:deploy

App deployed to: https://twilio-live-interactive-video-1234-5678-dev.twil.io?passcode=12345612345678
Passcode: 123 456 1234 5678
This URL is for demo purposes only. It will expire on Tue Oct 19 2021 14:58:20 GMT-0600 (Mountain Daylight Time)
```

If you make any changes to this application, you can run `npm run serverless:remove` followed by `npm run serverless:deploy` to deploy the new changes to your application.

**NOTE:** The Twilio Function that provides access tokens via a passcode should _NOT_ be used in a production environment. This token server supports seamlessly getting started with the collaboration app, and while convenient, the passcode is not secure enough for production environments. You should use an authentication provider to securely provide access tokens to your client applications. You can find more information about Programmable Video access tokens [in this tutorial](https://www.twilio.com/docs/video/tutorials/user-identity-access-tokens).

The passcode will expire after one week. To generate a new passcode, run `npm run serverless:deploy -- --override`. Additionally, you may run `npm run serverless:list` to see your deployed app's URL and passcode, or you can run `npm run serverless:remove` to delete the Serverless app from Twilio.

#### Max Stream Duration

The app is configured to automatically end a stream after it has been running for 30 minutes. This limitation is in place to limit the [charges applied to your Twilio account](https://www.twilio.com/live/pricing) during early testing.

Max duration is specified when the reference backend creates a `PlayerStreamer` and `MediaProcessor`. To change the max duration, edit [this source code](serverless/functions/create-stream.js#L78) before deploying the app.

### Use the web app

When you visit the URL for your deployed live streaming application, you'll first see a screen where you can enter your name. Then, you'll be prompted to either create a new streaming event and join the stream's Video Room as the event host, or join an existing event as either a speaker in the stream's Video Room or a stream audience member.

The application uses [Twilio Sync](https://www.twilio.com/docs/sync) and [Twilio Conversations](https://www.twilio.com/docs/conversations) to allow stream audience members to raise their hand and receive an invitation to join the stream as a speaker.

The first person to enter the Video Room as a speaker will be the event's host. This person can invite audience members into the stream and can end the stream when it is finished.

If you join a stream as an audience member, you can raise your hand to request to join the stream as a speaker. The host can then send you an invitation to join the stream, and send you back to the audience when you are done.

The application uses the [`video-composer-v1` Media Extension](https://www.twilio.com/docs/live/video-composer), which formats the Video Room contents in a responsive grid for streaming to audience members. People viewing the live stream will see all of the Video Room participants, and the grid will change as participants enter or exit.

#### Web app local development

To run the web app locally, you must first deploy the backend functions to Twilio Serverless. First, run `npm run serverless:deploy`, and then copy the URL of the deployed app to your `.env` file as the `WEB_PROXY_URL` variable (see [.env.example](.env.example) for an example). Then, run `npm run develop:web` to start the local development server. Any API requests made by the locally running app will be proxied to the URL provided as the `WEB_PROXY_URL`. 

If you want to edit the functions that have been deployed to Twilio Serverless, you can do so in the [Twilio Console Functions Editor](https://www.twilio.com/changelog/all-new-functions-and-assets-ui-now-available). 

### Run the iOS App

#### Open the Project in Xcode

1. [Open the iOS project](https://github.com/twilio/twilio-live-interactive-video/tree/main/apps/ios/LiveVideo/LiveVideo.xcodeproj) in Xcode.

#### Run

1. Run the app.
1. Enter any unique name in the `Full name` field and tap `Continue`.
1. Enter passcode from the [backend deploy](#deploy-the-app-to-twilio) and tap `Continue`.
1. Tap `Create Event` to host a new stream or `Join Event` to join a stream as a viewer or a speaker.

## Reference Backend

The API for the reference backend used by the clients is specified [here](ReferenceBackendAPI.md).

## Services Used

This application uses Twilio Functions, Twilio Conversations, and Twilio Sync in addition to Twilio Video Rooms and Twilio Live resources. Note that by deploying and using this application, your will be incurring usage for these services and will be billed for usage.
