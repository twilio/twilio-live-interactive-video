package com.twilio.livevideo.app.repository.datasource.remote

import com.google.gson.Gson
import com.twilio.livevideo.app.repository.model.VerifyPasscodeResponse
import com.twilio.livevideo.app.util.ApiResponseUtil
import javax.inject.Inject

class RemoteStorage @Inject constructor(private var liveVideoAPIService: LiveVideoAPIService) {

    private val gson = Gson()

    suspend fun verifyPasscode(passcode: String): VerifyPasscodeResponse {
        var result = VerifyPasscodeResponse()
        liveVideoAPIService.verifyPasscode(passcode)?.let { it ->
            if (!it.isSuccessful) {
                ApiResponseUtil.parseErrorBody(gson, it.errorBody(), result, VerifyPasscodeResponse::class.java)
            } else {
                result = it.body() ?: result
            }
            result.code = it.code()
            result.isApiResponseSuccess = it.errorBody() == null
        }
        return result
    }

}