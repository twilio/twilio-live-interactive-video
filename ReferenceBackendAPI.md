# Reference Backend API

## HTTP Method

The reference backend is deployed to [Twilio Functions](https://www.twilio.com/docs/runtime/functions), a serverless environment.

Twilio Functions does not utilize HTTP methods so you can just use `POST` for all requests.

## Authentication

All requests must set the `Authorization` header to the correct [passcode](README.md#deploy-the-app-to-twilio). The backend will validate the passcode before processing each request.

## Errors

All error responses have this shape:

```json
{
  "error": {
    "message": "error creating room",
    "explanation": "Room already exists."
  }
}
```

## Endpoints

### /verify-passcode

Verifies that the passcode in the request header is correct. The client can call this endpoint to validate a passcode the user has entered.

Request parameters:

```
None since the passcode to verify is in the request header
```

Example response:

```json
{
  "verified": true
}
```

### /create-stream

This endpoint creates a Twilio video room, Twilio Live player streamer, Twilio Live media processor, Twilio sync service, and Twilio conversation. The user is added to the conversation and some user state is updated in sync objects. The endpoint returns a [Twilio access token](https://www.twilio.com/docs/iam/access-tokens). The token includes grants that allow the client to connect to the Twilio Video SDK, Twilio Sync SDK, and Twilio Conversations SDK. The user that creates the stream is the host for that stream.

Request parameters:

```json
{
  "user_identity": "Bob",
  "stream_name": "demo"
}
```

Example response:

```json
{
  "token": "xxxx.yyyyy.zzzzz"
}
```

### /join-stream-as-speaker

This endpoint adds the user to the Twilio conversation and adds some user state to the sync objects. The endpoint returns a [Twilio access token](https://www.twilio.com/docs/iam/access-tokens). The token includes grants that allow the client to connect to the video room, sync objects, and conversation. The endpoint should be called when a user initially joins the stream as a speaker or when a user transitions from viewer to speaker.

Request parameters:

```json
{
  "user_identity": "Bob",
  "stream_name": "demo"
}
```

Example response:

```json
{
  "token": "xxxx.yyyyy.zzzzz"
}
```

### /join-stream-as-viewer

This endpoint adds the user to the Twilio conversation and adds some user state to some sync objects. The endpoint returns a [Twilio access token](https://www.twilio.com/docs/iam/access-tokens). The token includes grants that allow the client to connect to the live stream, sync objects, and conversation. 
The endpoint should be called when a user initially joins the stream as a viewer or when a user transitions from speaker to viewer.

Request parameters:

```json
{
  "user_identity": "Bob",
  "stream_name": "demo"
}
```

Example response:

```json
{
  "token": "xxxx.yyyyy.zzzzz"
}
```

### /viewer-connected-to-player

This endpoint updates some user state in the sync objects to reflect that the user is connected to the stream. The client should call this endpoint after a viewer successfully connects to the stream using the Twilio Live Player SDK.

Request parameters:

```json
{
  "user_identity": "Bob",
  "stream_name": "demo"
}
```

Example response:

```json
{
  "success": true
}
```

### /raise-hand

This endpoint updates sync objects to reflect that a user has either raised or lowered their hand. A client should call this endpoint when a viewer wants to signal to the host that they want to speak. The endpoint can also be called when a user changes their mind and wants to lower their hand.

Request parameters:

```json
{
  "user_identity": "Bob",
  "stream_name": "demo",
  "hand_raised": true
}
```

Example response:

```json
{
  "sent": true
}
```

### /remove-speaker

This endpoint removes a user from the video room. The endpoint should be called when a host wants to remove a speaker that causing shenanigans.

Request parameters:

```json
{
  "user_identity": "Bob",
  "room_name": "demo"
}
```

Example response:

```json
{
  "removed": true
}
```

### /send-speaker-invite

This endpoint updates some user state in a sync object to indicate that a user should be allowed to transition from a viewer to a speaker. The endpoint should be called by the host in response to a viewer raising their hand.

Request parameters:

```json
{
  "user_identity": "Bob",
  "room_sid": "RMd97f4196dabeb620c00564b95aec5dc2"
}
```

Example response:

```json
{
  "sent": true
}
```
