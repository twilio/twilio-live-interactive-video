package com.twilio.livevideo.app.di

import com.twilio.livevideo.app.BuildConfig
import com.twilio.livevideo.app.manager.AuthenticatorManager
import com.twilio.livevideo.app.network.LiveVideoRequestInterceptor
import com.twilio.livevideo.app.repository.datasource.local.LocalStorage
import com.twilio.livevideo.app.repository.datasource.local.LocalStorageImplFake
import com.twilio.livevideo.app.repository.datasource.remote.LiveVideoAPIService
import dagger.Module
import dagger.Provides
import dagger.hilt.components.SingletonComponent
import dagger.hilt.testing.TestInstallIn
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import org.mockito.kotlin.mock
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import javax.inject.Singleton

@Module
@TestInstallIn(
    components = [SingletonComponent::class],
    replaces = [MainModule::class]
)
class MainModuleFake {

    @Singleton
    @Provides
    fun provideTwilioLiveService(): LiveVideoAPIService = mock()

    @Provides
    fun provideLiveAppInterceptor(authenticatorManager: AuthenticatorManager): LiveVideoRequestInterceptor =
        LiveVideoRequestInterceptor(authenticatorManager)

    @Provides
    fun provideOkHttpClient(liveVideoRequestInterceptor: LiveVideoRequestInterceptor): OkHttpClient {
        val httpLoggingInterceptor = HttpLoggingInterceptor()
        httpLoggingInterceptor.level = HttpLoggingInterceptor.Level.BODY
        return OkHttpClient.Builder()
            .addInterceptor(httpLoggingInterceptor)
            .addInterceptor(liveVideoRequestInterceptor)
            .cache(null)
            .build()
    }

    @Singleton
    @Provides
    fun provideRetrofitClient(okHttpClient: OkHttpClient): Retrofit = Retrofit.Builder()
        .addConverterFactory(GsonConverterFactory.create())
        .baseUrl(BuildConfig.BASE_URL)
        .client(okHttpClient)
        .build()

    @Provides
    @Singleton
    fun provideLocalStorage(): LocalStorage =
        LocalStorageImplFake()

    @Provides
    fun provideDispatcherIO(): CoroutineDispatcher = Dispatchers.Main
}