package com.twilio.livevideo.app.viewmodel

import com.twilio.livevideo.app.repository.model.ErrorResponse

sealed class StreamViewEvent {
    data class OnConnectViewer(val token: String) : StreamViewEvent()
    data class OnCreateStream(val token: String) : StreamViewEvent()
    object OnDeleteStream : StreamViewEvent()
    data class OnStreamError(val error: ErrorResponse?) : StreamViewEvent()
}