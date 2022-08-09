package com.twilio.livevideo.app.repository.datasource.remote

import com.twilio.livevideo.app.network.LiveVideoRequestInterceptor
import com.twilio.livevideo.app.repository.model.CreateStreamResponse
import com.twilio.livevideo.app.repository.model.DeleteStreamResponse
import com.twilio.livevideo.app.repository.model.JoinStreamAsSpeakerResponse
import com.twilio.livevideo.app.repository.model.JoinStreamAsViewerResponse
import com.twilio.livevideo.app.repository.model.VerifyPasscodeResponse
import retrofit2.Response
import retrofit2.http.GET
import retrofit2.http.Header
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
}