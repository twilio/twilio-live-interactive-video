package com.twilio.livevideo.app.viewmodel

import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class CommonStreamViewModel @Inject constructor() : ViewModel() {

    var eventName: String = ""
    var userIdentity: String = ""

}