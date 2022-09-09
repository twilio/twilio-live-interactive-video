package com.twilio.livevideo.app.di

import androidx.fragment.app.Fragment
import com.twilio.livevideo.app.manager.GridManager
import com.twilio.livevideo.app.manager.PlayerManager
import com.twilio.livevideo.app.manager.permission.PermissionManager
import com.twilio.livevideo.app.manager.room.LocalParticipantWrapper
import com.twilio.livevideo.app.manager.room.RoomManager
import com.twilio.livevideo.app.manager.sync.SyncManager
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.components.FragmentComponent

@Module
@InstallIn(FragmentComponent::class)
class ComponentModule {

    @Provides
    fun providePermissionManager(fragment: Fragment): PermissionManager = PermissionManager(fragment)

    @Provides
    fun providePlayerManager(fragment: Fragment) = PlayerManager(fragment.context)

    @Provides
    fun provideRoomManager(fragment: Fragment, localParticipantWrapper: LocalParticipantWrapper): RoomManager =
        RoomManager(fragment.context, localParticipantWrapper)

    @Provides
    fun provideSyncManager(fragment: Fragment): SyncManager = SyncManager(fragment.context)

    @Provides
    fun provideLocalParticipantManager(fragment: Fragment): LocalParticipantWrapper = LocalParticipantWrapper(fragment.context)

    @Provides
    fun provideGridManager(): GridManager = GridManager()

}