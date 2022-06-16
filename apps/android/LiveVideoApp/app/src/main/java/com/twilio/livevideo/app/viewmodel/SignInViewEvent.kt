package com.twilio.livevideo.app.viewmodel

sealed class SignInViewEvent {
    object OnContinueName : SignInViewEvent()
    object OnContinuePasscode : SignInViewEvent()
}