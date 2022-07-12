package com.twilio.livevideo.app.viewmodel

import com.twilio.livevideo.app.repository.model.ErrorResponse

sealed class StreamViewEvent {
    data class OnConnectViewer(val token: String) : StreamViewEvent()
    data class OnConnectViewerError(val error: ErrorResponse?) : StreamViewEvent()
}