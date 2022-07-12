package com.twilio.livevideo.app.di

import androidx.fragment.app.Fragment
import com.twilio.livevideo.app.manager.PlayerManager
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.components.FragmentComponent

@Module
@InstallIn(FragmentComponent::class)
class ComponentModule {

    @Provides
    fun providePlayerManager(fragment: Fragment) = PlayerManager(fragment.context)

}