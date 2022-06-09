package com.twilio.livevideo.app.network

import okhttp3.Interceptor
import okhttp3.Response
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class LiveAppInterceptor @Inject constructor() : Interceptor {
    override fun intercept(chain: Interceptor.Chain): Response {
        val request = chain.request().newBuilder()
            //TODO: Get passcode from secure data cache, then modify the baseURL
            //TODO: Get authorization/passcode from secure data cache
            .header("Authorization", "123")
            .build()

        return chain.proceed(request)
    }
}