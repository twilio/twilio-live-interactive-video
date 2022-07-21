package com.twilio.livevideo.app.viewstate

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

data class StreamViewState(
    val role: ViewRole,
    val isLoading: Boolean = true,
    val eventName: String = "",
    val isLiveActive: Boolean = false
) {
    fun isViewerRole() = role == ViewRole.Viewer
}

sealed class ViewRole : Parcelable {
    @Parcelize
    object Host : ViewRole()

    @Parcelize
    object Speaker : ViewRole(), Parcelable

    @Parcelize
    object Viewer : ViewRole(), Parcelable
}