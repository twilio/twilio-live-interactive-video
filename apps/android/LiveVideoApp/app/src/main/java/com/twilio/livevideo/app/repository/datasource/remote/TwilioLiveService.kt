package com.twilio.livevideo.app.repository.datasource.remote

import com.twilio.livevideo.app.repository.model.GenericResponse
import retrofit2.Response
import retrofit2.http.GET

interface TwilioLiveService {

    @GET("verify-passcode")
    suspend fun verifyPasscode(): Response<GenericResponse>

}