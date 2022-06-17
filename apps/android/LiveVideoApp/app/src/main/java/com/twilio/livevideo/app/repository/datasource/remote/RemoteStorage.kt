package com.twilio.livevideo.app.repository.datasource.remote

import com.twilio.livevideo.app.repository.model.ErrorResponse
import com.twilio.livevideo.app.repository.model.GenericResponse

class RemoteStorage(private val twilioLiveService: TwilioLiveService) {

    suspend fun verifyPasscode(passcode: String): GenericResponse {
        val apiResponse = twilioLiveService.verifyPasscode()
        apiResponse.let { responseData ->
            responseData.body()?.apply {
                if (!responseData.isSuccessful) {
                    if (this.error == null) {
                        this.error = ErrorResponse()
                    }
                }
                this.code = responseData.code()
                this.isApiResponseSuccess = responseData.errorBody() != null
            }
        }
        return apiResponse.body() ?: GenericResponse()
    }

}