package com.twilio.livevideo.app.repository.datasource.remote

import com.google.gson.Gson
import com.twilio.livevideo.app.repository.model.BaseResponse
import com.twilio.livevideo.app.repository.model.CreateStreamResponse
import com.twilio.livevideo.app.repository.model.DeleteStreamResponse
import com.twilio.livevideo.app.repository.model.JoinStreamAsSpeakerResponse
import com.twilio.livevideo.app.repository.model.JoinStreamAsViewerResponse
import com.twilio.livevideo.app.repository.model.VerifyPasscodeResponse
import com.twilio.livevideo.app.util.ApiResponseUtil
import retrofit2.Response
import javax.inject.Inject

class RemoteStorage @Inject constructor(private var liveVideoAPIService: LiveVideoAPIService) {

    private val gson = Gson()

    suspend fun verifyPasscode(passcode: String): VerifyPasscodeResponse =
        processResponse(liveVideoAPIService.verifyPasscode(passcode))

    suspend fun joinStreamAsViewer(
        userIdentity: String,
        streamName: String
    ): JoinStreamAsViewerResponse =
        processResponse(liveVideoAPIService.joinStreamAsViewer(userIdentity, streamName))

    suspend fun createStream(
        userIdentity: String,
        streamName: String
    ): CreateStreamResponse =
        processResponse(liveVideoAPIService.createStream(userIdentity, streamName))

    suspend fun deleteStream(
        streamName: String
    ): DeleteStreamResponse =
        processResponse(liveVideoAPIService.deleteStream(streamName))

    suspend fun joinStreamAsSpeaker(
        userIdentity: String,
        streamName: String
    ): JoinStreamAsSpeakerResponse =
        processResponse(liveVideoAPIService.joinStreamAsSpeaker(userIdentity, streamName))

    private inline fun <reified T : BaseResponse> processResponse(
        response: Response<T>,
    ): T {
        val result: T = response.body() ?: T::class.java.newInstance()
        result.code = response.code()
        result.isApiResponseSuccess = response.errorBody() == null
        if (!response.isSuccessful) { // Failure case
            ApiResponseUtil.parseErrorBody(
                gson,
                response.errorBody(),
                result,
                T::class.java
            )
        }
        return result
    }

}