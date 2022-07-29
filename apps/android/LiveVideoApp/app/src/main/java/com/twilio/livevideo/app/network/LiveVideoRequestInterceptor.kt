package com.twilio.livevideo.app.network

import com.google.gson.Gson
import com.twilio.livevideo.app.manager.AuthenticatorManager
import com.twilio.livevideo.app.util.PasscodeUtil
import okhttp3.HttpUrl
import okhttp3.Interceptor
import okhttp3.Response
import okhttp3.ResponseBody
import timber.log.Timber
import javax.inject.Inject

class LiveVideoRequestInterceptor @Inject constructor(private val authenticatorManager: AuthenticatorManager) :
    Interceptor {

    private val gson = Gson()

    override fun intercept(chain: Interceptor.Chain): Response {
        val request = chain.request()
        val builder = request.newBuilder()
        val passcode = request.header(HEADER_AUTHORIZATION_KEY)
        val passcodeUrl = passcode?.let {
            PasscodeUtil.extractPasscodeUrl(passcode)
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
        val response = chain.proceed(builder.build())

        if (!response.isSuccessful) {
            Timber.d("Response Not Successful")
            response.apply {
                var bodyString = peekBody(2048).string()
                val contentType = this.body()?.contentType()
                if (bodyString.isEmpty() || "not found".equals(bodyString, true)) {
                    bodyString = "{\"error\":{\"message\":\"Error - ${response.code()}\",\"explanation\":\"${bodyString}\"}}"
                }
                val newResponseBody = ResponseBody.create(contentType, bodyString)

                // Set response code to 299 to make the request pass as successful to allow OkHttp convert/parse automatically the error response.
                // Otherwise, when there is an error code (<200 and >=300), Retrofit don't convert/parse the error response to allow
                // the developer parse the error to any Model
                return response.newBuilder()
                    .code(299)
                    .body(newResponseBody)
                    .build()
            }
        }

        return response
    }

    companion object {
        const val HEADER_AUTHORIZATION_KEY = "Authorization"
    }
}