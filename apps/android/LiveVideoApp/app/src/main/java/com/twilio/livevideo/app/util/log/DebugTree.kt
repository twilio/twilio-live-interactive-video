package com.twilio.livevideo.app.util.log

import timber.log.Timber

class DebugTree : Timber.DebugTree() {

    override fun log(priority: Int, tag: String?, message: String, t: Throwable?) {
        // Always log in debug
        super.log(priority, tag, message, t)

        // TODO: custom logging implementation if it's required.
    }

}