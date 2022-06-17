package com.twilio.livevideo.app.manager

import com.twilio.livevideo.app.repository.datasource.local.LocalStorage
import com.twilio.livevideo.app.repository.datasource.remote.RemoteStorage
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class AuthenticatorManager(
    private val localStorage: LocalStorage,
    private val remoteStorage: RemoteStorage
) {

    fun storeCredentials(passcode: String) {
        localStorage.putStringData(PASSCODE_KEY, passcode)
    }

    fun getCredentials(): String {
        return localStorage.getStringData(PASSCODE_KEY) ?: ""
    }

    suspend fun isPasscodeValid(): Boolean {
        val passcode = localStorage.getStringData(PASSCODE_KEY)
        if (passcode != null) {
            return withContext(Dispatchers.IO) {
                remoteStorage.verifyPasscode(passcode).isVerified ?: false
            }
        }
        return false
    }

    companion object {
        private const val PASSCODE_KEY = "USER-PASSCODE"
    }
}