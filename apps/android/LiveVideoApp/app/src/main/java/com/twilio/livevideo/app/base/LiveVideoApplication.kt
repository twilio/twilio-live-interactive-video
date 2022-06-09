package com.twilio.livevideo.app.base

import android.app.Application
import com.twilio.livevideo.app.BuildConfig
import com.twilio.livevideo.app.util.log.DebugTree
import com.twilio.video.LogLevel
import com.twilio.video.Video
import dagger.hilt.android.HiltAndroidApp
import timber.log.Timber

@HiltAndroidApp
class LiveVideoApplication : Application() {

    override fun onCreate() {
        super.onCreate()

        if (BuildConfig.DEBUG) {
            Video.setLogLevel(LogLevel.ALL)
            Timber.plant(DebugTree())
        }
    }
}