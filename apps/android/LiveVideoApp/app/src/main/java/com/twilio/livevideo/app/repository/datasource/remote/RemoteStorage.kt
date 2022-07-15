package com.twilio.livevideo.app.repository.datasource.remote

import com.google.gson.Gson
import com.twilio.livevideo.app.repository.model.BaseResponse
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
    ): JoinStreamAsViewerResponse {
        val respo = liveVideoAPIService.joinStreamAsViewer(userIdentity, streamName)
        return processResponse(respo)
    }

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