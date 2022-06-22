package com.twilio.livevideo.app.repository.datasource.remote

import com.twilio.livevideo.app.network.LiveVideoRequestInterceptor
import com.twilio.livevideo.app.repository.model.GenericResponse
import retrofit2.Response
import retrofit2.http.GET
import retrofit2.http.Header

interface LiveVideoAPIService {

    @GET("/verify-passcode")
    suspend fun verifyPasscode(@Header(LiveVideoRequestInterceptor.HEADER_AUTHORIZATION_KEY) passcode: String): Response<GenericResponse>?

}