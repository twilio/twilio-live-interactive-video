package com.twilio.livevideo.app.repository.datasource.remote

import com.google.gson.Gson
import com.twilio.livevideo.app.repository.model.JoinStreamAsViewerResponse
import com.twilio.livevideo.app.repository.model.VerifyPasscodeResponse
import com.twilio.livevideo.app.util.ApiResponseUtil
import javax.inject.Inject

class RemoteStorage @Inject constructor(private var liveVideoAPIService: LiveVideoAPIService) {

    private val gson = Gson()

    suspend fun verifyPasscode(passcode: String): VerifyPasscodeResponse =
        liveVideoAPIService.verifyPasscode(passcode).let {
            val result: VerifyPasscodeResponse = it.body() ?: VerifyPasscodeResponse(false)
            result.code = it.code()
            result.isApiResponseSuccess = it.errorBody() == null
            if (!it.isSuccessful) { // Failure case
                ApiResponseUtil.parseErrorBody(
                    gson,
                    it.errorBody(),
                    result,
                    VerifyPasscodeResponse::class.java
                )
            }
            result
        }

    suspend fun joinStreamAsViewer(
        userIdentity: String,
        streamName: String
    ): JoinStreamAsViewerResponse =
        liveVideoAPIService.joinStreamAsViewer(userIdentity, streamName).let {
            val result: JoinStreamAsViewerResponse = it.body() ?: JoinStreamAsViewerResponse("")
            result.code = it.code()
            result.isApiResponseSuccess = it.errorBody() == null
            if (!it.isSuccessful) { // Failure case
                ApiResponseUtil.parseErrorBody(
                    gson,
                    it.errorBody(),
                    result,
                    JoinStreamAsViewerResponse::class.java
                )
            }
            result
        }

}