package com.twilio.livevideo.app.network

import com.twilio.livevideo.app.manager.AuthenticatorManager
import okhttp3.HttpUrl
import okhttp3.Interceptor
import okhttp3.Response
import javax.inject.Inject

class LiveAppInterceptor @Inject constructor(private val authenticatorManager: AuthenticatorManager) :
    Interceptor {

    override fun intercept(chain: Interceptor.Chain): Response {
        val request = chain.request()
        val builder = request.newBuilder()
        val passcode = request.header(HEADER_AUTHORIZATION_KEY)
        val passcodeUrl = passcode?.let {
            authenticatorManager.extractPasscodeUrl(passcode)
        } ?: run {
            val authorizationValue = authenticatorManager.getPasscode()
            builder.addHeader(HEADER_AUTHORIZATION_KEY, authorizationValue)
            authenticatorManager.getPasscodeURL()
        }

        val baseUrl = authenticatorManager.getBaseURL(passcodeUrl)
        HttpUrl.parse(baseUrl)?.apply {
            val newUrl = request.url().newBuilder()
                .scheme(scheme())
                .host(url().toURI().host)
                .build()

            builder.url(newUrl)
        }
        return chain.proceed(builder.build())
    }

    companion object {
        const val HEADER_AUTHORIZATION_KEY = "Authorization"
    }
}