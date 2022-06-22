package com.twilio.livevideo.app.repository

import com.twilio.livevideo.app.manager.AuthenticatorManager
import com.twilio.livevideo.app.repository.datasource.remote.RemoteStorage
import com.twilio.livevideo.app.repository.model.GenericResponse
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class TwilioLiveRepository(
    private val remoteStorage: RemoteStorage,
    private val authenticator: AuthenticatorManager
) {

    suspend fun verifyPasscode(passcode: String): GenericResponse {
        return withContext(Dispatchers.IO) {
            val response = remoteStorage.verifyPasscode(passcode)
            if (response.isApiResponseSuccess) {
                authenticator.storePasscode(passcode)
            }
            response
        }
    }
}