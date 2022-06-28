package com.twilio.livevideo.app.di

import com.twilio.livevideo.app.repository.datasource.local.LocalStorage
import com.twilio.livevideo.app.repository.datasource.local.LocalStorageImplFake
import com.twilio.livevideo.app.repository.datasource.remote.LiveVideoAPIService
import dagger.Module
import dagger.Provides
import dagger.hilt.components.SingletonComponent
import dagger.hilt.testing.TestInstallIn
import org.mockito.kotlin.mock
import javax.inject.Singleton

@Module
@TestInstallIn(
    components = [SingletonComponent::class],
    replaces = [MainModule::class]
)
class MainModuleFake {

    @Provides
    fun provideTwilioLiveService(): LiveVideoAPIService = mock()

    @Provides
    @Singleton
    fun provideLocalStorage(): LocalStorage =
        LocalStorageImplFake()

}