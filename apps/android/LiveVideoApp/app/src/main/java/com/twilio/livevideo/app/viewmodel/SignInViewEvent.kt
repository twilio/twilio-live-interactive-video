package com.twilio.livevideo.app.viewmodel

import com.twilio.livevideo.app.repository.model.ErrorResponse

sealed class SignInViewEvent {
    object OnContinueName : SignInViewEvent()
    object OnContinuePasscode : SignInViewEvent()
    data class OnSignInError(val error: ErrorResponse?) : SignInViewEvent()
}