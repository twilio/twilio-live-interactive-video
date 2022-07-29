package com.twilio.livevideo.app.repository.datasource.remote

import com.twilio.livevideo.app.repository.model.BaseResponse
import com.twilio.livevideo.app.repository.model.CreateStreamResponse
import com.twilio.livevideo.app.repository.model.DeleteStreamResponse
import com.twilio.livevideo.app.repository.model.JoinStreamAsViewerResponse
import com.twilio.livevideo.app.repository.model.VerifyPasscodeResponse
import retrofit2.Response
import javax.inject.Inject

class RemoteStorage @Inject constructor(private var liveVideoAPIService: LiveVideoAPIService) {

    suspend fun verifyPasscode(passcode: String): VerifyPasscodeResponse = liveVideoAPIService.verifyPasscode(passcode).let { response ->
        (response.body() ?: VerifyPasscodeResponse()).also { setBaseResponse(it, response) }
    }

    suspend fun joinStreamAsViewer(
        userIdentity: String,
        streamName: String
    ): JoinStreamAsViewerResponse = liveVideoAPIService.joinStreamAsViewer(userIdentity, streamName).let { response ->
        (response.body() ?: JoinStreamAsViewerResponse()).also { setBaseResponse(it, response) }
    }

    suspend fun createStream(
        userIdentity: String,
        streamName: String
    ): CreateStreamResponse = liveVideoAPIService.createStream(userIdentity, streamName).let { response ->
        (response.body() ?: CreateStreamResponse()).also { setBaseResponse(it, response) }
    }

    suspend fun deleteStream(
        streamName: String
    ): DeleteStreamResponse = liveVideoAPIService.deleteStream(streamName).let { response ->
        (response.body() ?: DeleteStreamResponse()).also { setBaseResponse(it, response) }
    }

    private fun <T : BaseResponse> setBaseResponse(result: T, response: Response<T>) {
        result.code = response.code()
        result.isApiResponseSuccess = response.code() != 299
    }

}