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

### Use the app

When you visit the URL for your deployed live streaming application, you'll be able to create and join a Twilio Video Room.

![View of the application's landing page](https://twilio-cms-prod.s3.amazonaws.com/images/Screen_Shot_2021-09-07_at_5.05.14_PM.width-1000.png)

When you have created and joined a Video Room, you can retrieve the audience URL for streaming the room by going to **More -> About** in the menu bar at the bottom of the application. You will then see the **Stream Player URL**, which you can visit to view the audience stream for the Video Room.

![View of the More -> About menu bar](https://twilio-cms-prod.s3.amazonaws.com/images/Screen_Shot_2021-09-07_at_5.19.22_PM.width-1000.png)
