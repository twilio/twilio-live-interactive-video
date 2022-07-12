package com.twilio.livevideo.app.manager

import com.twilio.livevideo.app.BuildConfig
import com.twilio.livevideo.app.repository.datasource.local.LocalStorage
import com.twilio.livevideo.app.util.PasscodeUtil
import javax.inject.Inject

class AuthenticatorManager @Inject constructor(
    private val localStorage: LocalStorage
) {

    fun storeCredentials(passcode: String, userName: String) {
        localStorage.putStringData(FULL_PASSCODE_KEY, passcode)
        localStorage.putStringData(URL_PASSCODE_KEY, PasscodeUtil.extractPasscodeUrl(passcode))
        localStorage.putStringData(USER_NAME_KEY, userName)
    }

    fun clearCredentials() {
        localStorage.clearData()
    }

    fun getUserName(): String = localStorage.getStringData(USER_NAME_KEY) ?: ""

    fun getPasscode(): String = localStorage.getStringData(FULL_PASSCODE_KEY) ?: ""

    fun getPasscodeURL(): String = localStorage.getStringData(URL_PASSCODE_KEY) ?: ""

    fun isPasscodeValid(): Boolean = getPasscode().isNotEmpty()

    fun getBaseURL(passcodeUrl: String): String =
        BuildConfig.BASE_URL.replace("passcode", passcodeUrl).trim()

    companion object {
        private const val FULL_PASSCODE_KEY = "FULL-PASSCODE"
        private const val URL_PASSCODE_KEY = "URL-PASSCODE"
        private const val USER_NAME_KEY = "USER-NAME"
    }
}