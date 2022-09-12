package com.twilio.livevideo.app.di

import android.content.Context
import androidx.fragment.app.Fragment
import androidx.lifecycle.Lifecycle
import androidx.test.platform.app.InstrumentationRegistry
import com.twilio.live.player.PlayerView
import com.twilio.livevideo.app.manager.PlayerManager
import com.twilio.livevideo.app.manager.PlayerManagerFake
import com.twilio.livevideo.app.manager.sync.SyncManager
import com.twilio.livevideo.app.manager.sync.SyncManagerFake
import dagger.Module
import dagger.Provides
import dagger.hilt.android.components.FragmentComponent
import dagger.hilt.testing.TestInstallIn

@Module
@TestInstallIn(
    components = [FragmentComponent::class],
    replaces = [ComponentModule::class]
)
class ComponentModuleFake {

    @Provides
    fun provideAppContext(): Context = InstrumentationRegistry.getInstrumentation().context

    @Provides
    fun providePlayerManager(appContext: Context): PlayerManager = object : PlayerManagerFake(appContext) {
        override fun connect(lifecycle: Lifecycle, playerView: PlayerView, accessToken: String) {
            init(lifecycle)
            connectUnit?.invoke()
        }
    }

    @Provides
    fun provideSyncManager(fragment: Fragment): SyncManager = SyncManagerFake(fragment.context)

}