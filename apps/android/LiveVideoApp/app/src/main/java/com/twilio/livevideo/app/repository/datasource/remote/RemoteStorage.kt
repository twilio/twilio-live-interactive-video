package com.twilio.livevideo.app.repository.datasource.remote

import com.google.gson.Gson
import com.google.gson.JsonSyntaxException
import com.twilio.livevideo.app.repository.model.GenericResponse
import timber.log.Timber
import javax.inject.Inject

class RemoteStorage @Inject constructor(private var liveVideoAPIService: LiveVideoAPIService) {

    private val gson = Gson()

    suspend fun verifyPasscode(passcode: String): GenericResponse {
        var result = GenericResponse()
        liveVideoAPIService.verifyPasscode(passcode)?.let { it ->
            if (!it.isSuccessful) {
                try {
                    gson.fromJson(it.errorBody()?.charStream(), GenericResponse::class.java)
                        ?.apply {
                            result.error = this.error
                        }
                } catch (ex: JsonSyntaxException) {
                    Timber.e(ex.message)
                }
            } else {
                result = it.body() ?: result
            }
            result.code = it.code()
            result.isApiResponseSuccess = it.errorBody() == null
        }
        return result
    }

}