package com.twilio.livevideo.app.di

import android.content.Context
import com.twilio.livevideo.app.BuildConfig
import com.twilio.livevideo.app.manager.AuthenticatorManager
import com.twilio.livevideo.app.network.LiveVideoRequestInterceptor
import com.twilio.livevideo.app.repository.LiveVideoRepository
import com.twilio.livevideo.app.repository.datasource.local.LocalStorage
import com.twilio.livevideo.app.repository.datasource.local.LocalStorageImpl
import com.twilio.livevideo.app.repository.datasource.remote.LiveVideoAPIService
import com.twilio.livevideo.app.repository.datasource.remote.RemoteStorage
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
class MainModule {

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
    fun provideTwilioLiveService(retrofit: Retrofit): LiveVideoAPIService =
        retrofit.create(LiveVideoAPIService::class.java)

    @Singleton
    @Provides
    fun provideLocalStorage(@ApplicationContext context: Context): LocalStorage =
        LocalStorageImpl(context)

    @Singleton
    @Provides
    fun provideRemoteStorage(liveVideoAPIService: LiveVideoAPIService, retrofit: Retrofit): RemoteStorage =
        RemoteStorage(liveVideoAPIService, retrofit)

    @Provides
    fun provideAuthenticatorManager(
        localStorage: LocalStorage
    ): AuthenticatorManager = AuthenticatorManager(localStorage)

    @Provides
    fun provideTwilioLiveRepository(
        remoteStorage: RemoteStorage,
        authenticatorManager: AuthenticatorManager,
        dispatcher: CoroutineDispatcher
    ): LiveVideoRepository = LiveVideoRepository(remoteStorage, authenticatorManager, dispatcher)

    @Provides
    fun provideDispatcherIO(): CoroutineDispatcher = Dispatchers.IO
}