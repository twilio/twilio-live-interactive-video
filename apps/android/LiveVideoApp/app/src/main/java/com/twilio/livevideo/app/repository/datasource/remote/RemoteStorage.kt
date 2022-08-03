package com.twilio.livevideo.app.repository.datasource.remote

import com.google.gson.stream.MalformedJsonException
import com.twilio.livevideo.app.repository.model.BaseResponse
import com.twilio.livevideo.app.repository.model.CreateStreamResponse
import com.twilio.livevideo.app.repository.model.DeleteStreamResponse
import com.twilio.livevideo.app.repository.model.ErrorResponse
import com.twilio.livevideo.app.repository.model.JoinStreamAsViewerResponse
import com.twilio.livevideo.app.repository.model.VerifyPasscodeResponse
import retrofit2.Response
import retrofit2.Retrofit
import javax.inject.Inject

class RemoteStorage @Inject constructor(private val liveVideoAPIService: LiveVideoAPIService, private val retrofit: Retrofit) {

    suspend fun verifyPasscode(passcode: String): VerifyPasscodeResponse =
        validateResponse(liveVideoAPIService.verifyPasscode(passcode))

    suspend fun joinStreamAsViewer(
        userIdentity: String,
        streamName: String
    ): JoinStreamAsViewerResponse =
        validateResponse(liveVideoAPIService.joinStreamAsViewer(userIdentity, streamName))

    suspend fun createStream(
        userIdentity: String,
        streamName: String
    ): CreateStreamResponse =
        validateResponse(liveVideoAPIService.createStream(userIdentity, streamName))

    suspend fun deleteStream(
        streamName: String
    ): DeleteStreamResponse =
        validateResponse(liveVideoAPIService.deleteStream(streamName))

    private inline fun <reified T : BaseResponse> validateResponse(
        response: Response<T>,
    ): T {
        val result: T = if (!response.isSuccessful) { // Failure case
            response.errorBody()?.let { body ->
                try {
                    retrofit.responseBodyConverter<T>(T::class.java, arrayOf()).convert(body)
                } catch (e: MalformedJsonException) {
                    null
                }
            } ?: T::class.java.newInstance().apply {
                val explanation = if (code == 404)
                    ""
                else
                    "MalformedJsonException"
                error = ErrorResponse("Error - ${response.code()}", explanation)
            }
        } else {
            response.body()!!
        }

        result.code = response.code()
        result.isApiResponseSuccess = response.errorBody() == null
        return result
    }

}