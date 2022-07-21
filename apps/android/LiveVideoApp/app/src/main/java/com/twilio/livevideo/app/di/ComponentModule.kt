package com.twilio.livevideo.app.di

import androidx.fragment.app.Fragment
import com.twilio.livevideo.app.manager.PlayerManager
import com.twilio.livevideo.app.manager.room.LocalParticipantWrapper
import com.twilio.livevideo.app.manager.room.RoomManager
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.components.FragmentComponent

@Module
@InstallIn(FragmentComponent::class)
class ComponentModule {

    @Provides
    fun providePlayerManager(fragment: Fragment) = PlayerManager(fragment.context)

    @Provides
    fun provideRoomManager(fragment: Fragment, localParticipantWrapper: LocalParticipantWrapper): RoomManager =
        RoomManager(fragment.context, localParticipantWrapper)

    @Provides
    fun provideLocalParticipantManager(fragment: Fragment): LocalParticipantWrapper = LocalParticipantWrapper(fragment.context)

}