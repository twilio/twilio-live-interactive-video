package com.twilio.livevideo.app.di

import android.content.Context
import com.twilio.livevideo.app.BuildConfig
import com.twilio.livevideo.app.manager.AuthenticatorManager
import com.twilio.livevideo.app.network.LiveAppInterceptor
import com.twilio.livevideo.app.repository.TwilioLiveRepository
import com.twilio.livevideo.app.repository.datasource.local.LocalStorage
import com.twilio.livevideo.app.repository.datasource.local.LocalStorageImpl
import com.twilio.livevideo.app.repository.datasource.remote.RemoteStorage
import com.twilio.livevideo.app.repository.datasource.remote.TwilioLiveService
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
class MainModule {

    @Singleton
    @Provides
    fun provideOkHttpClient(liveAppInterceptor: LiveAppInterceptor): OkHttpClient {
        val httpLoggingInterceptor = HttpLoggingInterceptor()
        httpLoggingInterceptor.level = HttpLoggingInterceptor.Level.BODY
        return OkHttpClient.Builder()
            .addInterceptor(httpLoggingInterceptor)
            .addInterceptor(liveAppInterceptor)
            .build()
    }

    @Singleton
    @Provides
    fun provideRetrofitClient(okHttpClient: OkHttpClient): Retrofit {
        return Retrofit.Builder()
            .addConverterFactory(GsonConverterFactory.create())
            .baseUrl(BuildConfig.BASE_URL)
            .client(okHttpClient)
            .build()
    }

    @Singleton
    @Provides
    fun provideTwilioLiveService(retrofit: Retrofit): TwilioLiveService {
        return retrofit.create(TwilioLiveService::class.java)
    }

    @Singleton
    @Provides
    fun provideLocalStorage(@ApplicationContext context: Context): LocalStorage =
        LocalStorageImpl(context)

    @Singleton
    @Provides
    fun provideRemoteStorage(twilioLiveService: TwilioLiveService): RemoteStorage =
        RemoteStorage(twilioLiveService)

    @Provides
    fun provideAuthenticatorManager(
        localStorage: LocalStorage,
        remoteStorage: RemoteStorage
    ): AuthenticatorManager = AuthenticatorManager(localStorage, remoteStorage)

    @Provides
    fun provideTwilioLiveRepository(
        remoteStorage: RemoteStorage,
        authenticatorManager: AuthenticatorManager
    ): TwilioLiveRepository = TwilioLiveRepository(remoteStorage, authenticatorManager)

}