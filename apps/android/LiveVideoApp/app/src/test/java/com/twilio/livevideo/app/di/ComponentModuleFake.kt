package com.twilio.livevideo.app.di

import android.content.Context
import androidx.lifecycle.Lifecycle
import androidx.test.platform.app.InstrumentationRegistry
import com.twilio.live.player.PlayerState
import com.twilio.live.player.PlayerView
import com.twilio.livevideo.app.manager.PlayerManager
import com.twilio.livevideo.app.manager.PlayerManagerFake
import dagger.Module
import dagger.Provides
import dagger.hilt.components.SingletonComponent
import dagger.hilt.testing.TestInstallIn
import org.mockito.kotlin.mock

@Module
@TestInstallIn(
    components = [SingletonComponent::class],
    replaces = [ComponentModule::class]
)
class ComponentModuleFake {

    @Provides
    fun provideAppContext(): Context = InstrumentationRegistry.getInstrumentation().context

    @Provides
    fun providePlayerManager(appContext: Context) : PlayerManager = object : PlayerManagerFake(appContext) {
        override fun connect(lifecycle: Lifecycle, playerView: PlayerView, accessToken: String) {
            init(lifecycle)
            connectUnit?.invoke()
        }
    }

}