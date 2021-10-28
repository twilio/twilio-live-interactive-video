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
* NPM v7+ (upgrade from NPM 6 with `npm install --global npm`)

### Setup Enviromenment

Copy the `.env.example` file to `.env` and perform the following one-time steps before deploying your application. 

#### Set your Account Sid and Auth Token

Update the ACCOUNT_SID and AUTH_TOKEN `.env` entries with the Account SID and Auth Token found on the [Twilio Console home page](https://twilio.com/console).

#### Install Dependencies

Once you have setup all your environment variables, run `npm install` to install all dependencies from NPM.

### Deploy the app to Twilio

Once the application environment has been configured and dependencies have been installed, you can deploy the app backend and web app using the following command.

```shell
npm run serverless:deploy

App deployed to: https://twilio-live-interactive-video-1234-5678-dev.twil.io
Passcode: 123 456 1234 5678
This URL is for demo purposes only. It will expire on Tue Oct 19 2021 14:58:20 GMT-0600 (Mountain Daylight Time)
```

If you make any changes to this application, you can run `npm run serverless:remove` followed by `npm run serverless:deploy` to deploy the new changes to your application.

### Use the web app

When you visit the URL for your deployed live streaming application, you'll first see a screen where you can enter your name. Then, you'll be prompted to either create a new streaming event and join the stream's Video Room as the event host, or join an existing event as either a speaker in the stream's Video Room or a stream audience member.

The application uses [Twilio Sync](https://www.twilio.com/docs/sync) and [Twilio Conversations](https://www.twilio.com/docs/conversations) to allow stream audience members to raise their hand and receive an invitation to join the stream as a speaker.

The first person to enter the Video Room as a speaker will be the event's host. This person can invite audience members into the stream and can end the stream when it is finished.

If you join a stream as an audience member, you can raise your hand to request to join the stream as a speaker. The host can then send you an invitation to join the stream, and send you back to the audience when you are done.

The application uses the [`video-composer-v1` Media Extension](https://www.twilio.com/docs/live/video-composer), which formats the Video Room contents in a responsive grid for streaming to audience members. People viewing the live stream will see all of the Video Room participants, and the grid will change as participants enter or exit.

### Run the iOS App

#### Open the Project in Xcode

1. [Open the iOS project](https://github.com/twilio/twilio-live-interactive-video/tree/main/apps/ios/LiveVideo/LiveVideo.xcodeproj) in Xcode.

#### Configure Backend URL

1.  Replace `BACKEND_URL` in the [iOS app source](https://github.com/twilio/twilio-live-interactive-video/blob/main/apps/ios/LiveVideo/LiveVideo/Managers/API/API.swift) with [the URL that the app was deployed to](#deploy-the-app-to-twilio).

#### Run

1. Run the app.
1. Enter any unique name in the `Full name` field.
1. Tap `Continue`.
1. Tap `Create Event` to host a new stream or `Join Event` to join a stream as a viewer or a speaker.
