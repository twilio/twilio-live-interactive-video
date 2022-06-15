package com.twilio.livevideo.app.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class HomeEventNameViewModel @Inject constructor() : ViewModel() {

    val newEventName = MutableLiveData<String>()

    val joinEventName = MutableLiveData<String>()

    private val _isNewEvent = MutableLiveData<Boolean>()
    val isNewEvent: LiveData<Boolean>
        get() = _isNewEvent

    private val _continueNewEventEnabled = MutableLiveData<Boolean>()
    val continueNewEventEnabled: LiveData<Boolean>
        get() = _continueNewEventEnabled

    private val _continueJoinEventEnabled = MutableLiveData<Boolean>()
    val continueJoinEventEnabled: LiveData<Boolean>
        get() = _continueJoinEventEnabled

    fun enableNewEventContinue(value: Boolean?) {
        _continueNewEventEnabled.value = value ?: false
    }

    fun enableJoinEventContinue(value: Boolean?) {
        _continueJoinEventEnabled.value = value ?: false
    }

    fun setNewEvent(value: Boolean) {
        _isNewEvent.value = value
    }

}