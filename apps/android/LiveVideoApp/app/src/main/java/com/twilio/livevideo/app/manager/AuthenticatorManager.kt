package com.twilio.livevideo.app.manager

import com.twilio.livevideo.app.BuildConfig
import com.twilio.livevideo.app.repository.datasource.local.LocalStorage

class AuthenticatorManager(
    private val localStorage: LocalStorage
) {

    fun storePasscode(passcode: String) {
        localStorage.putStringData(FULL_PASSCODE_KEY, passcode)
        localStorage.putStringData(URL_PASSCODE_KEY, extractPasscodeUrl(passcode))
    }

    fun getPasscode(): String = localStorage.getStringData(FULL_PASSCODE_KEY) ?: ""

    fun getPasscodeURL(): String = localStorage.getStringData(URL_PASSCODE_KEY) ?: ""

    fun isPasscodeValid(): Boolean = getPasscode().isNotEmpty()

    fun extractPasscodeUrl(passcode: String): String {
        var passcodeUrl = passcode.substring(passcode.length - 8)
        passcodeUrl =
            "${passcodeUrl.substring(0, 4)}-${passcodeUrl.substring(4, passcodeUrl.length)}"
        return passcodeUrl.trim()
    }

    fun getBaseURL(passcodeUrl: String): String =
        BuildConfig.BASE_URL.replace("passcode", passcodeUrl).trim()

    companion object {
        private const val FULL_PASSCODE_KEY = "FULL-PASSCODE"
        private const val URL_PASSCODE_KEY = "URL-PASSCODE"
    }
}