package com.twilio.livevideo.app.repository.datasource.remote

import com.twilio.livevideo.app.network.LiveVideoRequestInterceptor
import com.twilio.livevideo.app.repository.model.CreateStreamResponse
import com.twilio.livevideo.app.repository.model.DeleteStreamResponse
import com.twilio.livevideo.app.repository.model.JoinStreamAsSpeakerResponse
import com.twilio.livevideo.app.repository.model.JoinStreamAsViewerResponse
import com.twilio.livevideo.app.repository.model.RaiseHandParameters
import com.twilio.livevideo.app.repository.model.RaiseHandResponse
import com.twilio.livevideo.app.repository.model.RemoveSpeakerResponse
import com.twilio.livevideo.app.repository.model.SendSpeakerInviteResponse
import com.twilio.livevideo.app.repository.model.VerifyPasscodeResponse
import com.twilio.livevideo.app.repository.model.ViewerConnectedToPlayerResponse
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.POST
import retrofit2.http.Query

interface LiveVideoAPIService {

    @GET("/verify-passcode")
    suspend fun verifyPasscode(@Header(LiveVideoRequestInterceptor.HEADER_AUTHORIZATION_KEY) passcode: String): Response<VerifyPasscodeResponse>

    @GET("/join-stream-as-viewer")
    suspend fun joinStreamAsViewer(
        @Query("user_identity") userIdentity: String,
        @Query("stream_name") streamName: String
    ): Response<JoinStreamAsViewerResponse>

    @GET("/create-stream")
    suspend fun createStream(
        @Query("user_identity") userIdentity: String,
        @Query("stream_name") streamName: String
    ): Response<CreateStreamResponse>

    @GET("/delete-stream")
    suspend fun deleteStream(
        @Query("stream_name") streamName: String
    ): Response<DeleteStreamResponse>

    @GET("/join-stream-as-speaker")
    suspend fun joinStreamAsSpeaker(
        @Query("user_identity") userIdentity: String,
        @Query("stream_name") streamName: String
    ): Response<JoinStreamAsSpeakerResponse>

    @GET("/remove-speaker")
    suspend fun removeSpeaker(
        @Query("user_identity") userIdentity: String,
        @Query("room_name") roomName: String
    ): Response<RemoveSpeakerResponse>

    @POST("/raise-hand")
    suspend fun raiseHand(@Body body: RaiseHandParameters): Response<RaiseHandResponse>

    @GET("/send-speaker-invite")
    suspend fun sendSpeakerInvite(
        @Query("user_identity") userIdentity: String,
        @Query("room_sid") roomSid: String
    ): Response<SendSpeakerInviteResponse>

    @GET("/viewer-connected-to-player")
    suspend fun viewerConnectedToPlayer(
        @Query("user_identity") userIdentity: String,
        @Query("stream_name") streamName: String
    ): Response<ViewerConnectedToPlayerResponse>
}