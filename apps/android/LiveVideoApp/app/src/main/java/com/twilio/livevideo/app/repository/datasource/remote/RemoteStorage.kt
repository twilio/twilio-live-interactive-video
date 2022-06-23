package com.twilio.livevideo.app.repository.datasource.remote

import com.google.gson.Gson
import com.twilio.livevideo.app.repository.model.ErrorResponse
import com.twilio.livevideo.app.repository.model.VerifyPasscodeResponse
import com.twilio.livevideo.app.util.ApiResponseUtil
import javax.inject.Inject

class RemoteStorage @Inject constructor(private var liveVideoAPIService: LiveVideoAPIService) {

    private val gson = Gson()

    suspend fun verifyPasscode(passcode: String): VerifyPasscodeResponse =
        liveVideoAPIService.verifyPasscode(passcode)?.let { it ->
            val result: VerifyPasscodeResponse = it.body() ?: VerifyPasscodeResponse(false)
            result.code = it.code()
            result.isApiResponseSuccess = it.errorBody() == null
            if (!it.isSuccessful) { // Failure case
                ApiResponseUtil.parseErrorBody(gson, it.errorBody(), result, VerifyPasscodeResponse::class.java)
            }
            result
        } ?: run {
            VerifyPasscodeResponse(false)
        }

}