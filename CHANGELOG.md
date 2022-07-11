# 1.1.0 (July 11, 2022)

### New Feature

- This release adds a chat feature for the host, speakers, and viewers. This feature allows all users to send and receive textual messages to each other while connected to a stream. This feature is powered by the [Twilio Conversations API](https://www.twilio.com/conversations-api) and is optional. See the [README.md](https://github.com/twilio/twilio-live-interactive-video/blob/feature/audience-chat/README.md#set-your-account-sid-and-auth-token) for more information on how to opt out.

### Bug Fixes

- Fixes an issue where the host could not create more than one stream. [#116](https://github.com/twilio/twilio-live-interactive-video/pull/116)

# 1.0.0 (February 28, 2022)

This is the initial release of the Twilio Live Interactive Video iOS and web Apps. This project demonstrates an interactive live video streaming app that uses [Twilio Live](https://www.twilio.com/docs/live), [Twilio Video](https://www.twilio.com/docs/video) and [Twilio Sync](https://www.twilio.com/docs/sync).

This release includes the following features:

- Deploy the application to Twilio Serverless in just a few minutes.
- Create or join a stream as a speaker and collaborate with other users.
- Join a stream as a viewer to see the Twilio Video Room participants composed as a high quality media stream.
- Speakers can screen share content of their choice to the other participants and viewers.
- Viewers can "raise" and "lower" their hands in order to request to be a speaker.
- Host participant can invite viewers that raise their hands to join the stream as a speaker. 
- Host participant can mute other speakers as well as move them to the list of viewers.
- All live streaming participants can view the list of speakers and viewers in real time.

We intend to iterate on this initial set of features and we look forward to collaborating with the community.