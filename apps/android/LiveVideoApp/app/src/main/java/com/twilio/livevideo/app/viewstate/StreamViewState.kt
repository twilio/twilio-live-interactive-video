package com.twilio.livevideo.app.viewstate

import android.os.Parcelable
import com.twilio.livevideo.app.manager.room.ParticipantStream
import kotlinx.parcelize.Parcelize

data class StreamViewState(
    val role: ViewRole,
    val isLoading: Boolean = true,
    val eventName: String = "",
    val isLiveActive: Boolean = false,
) {
    fun isViewerRole() = role == ViewRole.Viewer
    fun isSpeakerRole() = role == ViewRole.Speaker
}

sealed class ViewRole : Parcelable {
    @Parcelize
    object Host : ViewRole()

    @Parcelize
    object Speaker : ViewRole(), Parcelable

    @Parcelize
    object Viewer : ViewRole(), Parcelable
}