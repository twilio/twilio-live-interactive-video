package com.twilio.livevideo.app.base

import android.app.Application
import com.twilio.live.player.Player
import com.twilio.livevideo.app.BuildConfig
import com.twilio.livevideo.app.util.log.DebugTree
import com.twilio.sync.SyncClient
import com.twilio.video.Video
import dagger.hilt.android.HiltAndroidApp
import timber.log.Timber

@HiltAndroidApp
class LiveVideoApplication : Application() {

    override fun onCreate() {
        super.onCreate()

        if (BuildConfig.DEBUG) {
            SyncClient.setLogLevel(SyncClient.LogLevel.DEBUG)
            Video.setLogLevel(com.twilio.video.LogLevel.DEBUG)
            Player.logLevel = com.twilio.live.player.LogLevel.DEBUG
            Timber.plant(DebugTree())
        }
    }
}