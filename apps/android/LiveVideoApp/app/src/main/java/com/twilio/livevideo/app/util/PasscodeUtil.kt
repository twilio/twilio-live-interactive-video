package com.twilio.livevideo.app.util

class PasscodeUtil {
    companion object {
        private const val SHORT_PASSCODE_LENGTH = 6
        private const val APP_ID_LENGTH = 4
        private const val SERVERLESS_ID_MIN_LENGTH = 4
        const val FULL_PASSCODE_MIN_LENGTH =
            SHORT_PASSCODE_LENGTH + APP_ID_LENGTH + SERVERLESS_ID_MIN_LENGTH

        fun extractPasscodeUrl(fullPasscode: String): String {
            val appId =
                fullPasscode.substring(SHORT_PASSCODE_LENGTH, SHORT_PASSCODE_LENGTH + APP_ID_LENGTH)
            val serverlessId =
                fullPasscode.substring(SHORT_PASSCODE_LENGTH + APP_ID_LENGTH, fullPasscode.length)
            return "$appId-$serverlessId"
        }
    }
}