package com.twilio.livevideo.app.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.twilio.livevideo.app.annotations.OpenForTesting
import com.twilio.livevideo.app.repository.LiveVideoRepository
import com.twilio.livevideo.app.viewstate.StreamViewState
import com.twilio.livevideo.app.viewstate.ViewRole
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import timber.log.Timber
import javax.inject.Inject

@HiltViewModel
@OpenForTesting
class StreamViewModel @Inject constructor(
    private val liveVideoRepository: LiveVideoRepository
) :
    ViewModel() {

    private val _viewState: MutableLiveData<StreamViewState> = MutableLiveData<StreamViewState>()
    val viewState: LiveData<StreamViewState>
        get() = _viewState

    private val _screenEvent: MutableLiveData<StreamViewEvent?> = MutableLiveData()
    val screenEvent: LiveData<StreamViewEvent?>
        get() {
            val event = _screenEvent
            _screenEvent.value = null
            return event
        }

    fun initViewState(role: ViewRole) {
        _viewState.value = StreamViewState(role)
    }

    fun onLoadingFinish(isLiveActive: Boolean = false) {
        _viewState.value = _viewState.value?.copy(isLoading = false, isLiveActive = isLiveActive)
    }

    fun joinStreamAsViewer(eventName: String) {
        viewModelScope.launch {
            _viewState.value = _viewState.value?.copy(
                isLoading = true,
                eventName = eventName,
                isLiveActive = false
            )
            val response = liveVideoRepository.joinStreamAsViewer(eventName)
            if (response.isApiResponseSuccess && response.token.isNotEmpty()) {
                _screenEvent.value = StreamViewEvent.OnConnectViewer(response.token)
            } else {
                _screenEvent.value = StreamViewEvent.OnStreamError(response.error)
                _viewState.value = _viewState.value?.copy(isLoading = false, isLiveActive = false)
            }
        }
    }

    fun createStream(eventName: String) {
        viewModelScope.launch {
            _viewState.value = _viewState.value?.copy(
                isLoading = true,
                eventName = eventName,
                isLiveActive = false
            )
            val response = liveVideoRepository.createStream(eventName)
            if (response.isApiResponseSuccess && response.token.isNotEmpty()) {
                _screenEvent.value = StreamViewEvent.OnCreateStream(response.token)
            } else {
                _screenEvent.value = StreamViewEvent.OnStreamError(response.error)
                _viewState.value = _viewState.value?.copy(isLoading = false, isLiveActive = false)
            }
        }
    }

    fun deleteStream() {
        viewState.value?.eventName?.let { streamName ->
            viewModelScope.launch {
                _viewState.value = _viewState.value?.copy(
                    isLiveActive = false
                )
                val response = liveVideoRepository.deleteStream(streamName)
                if (response.isApiResponseSuccess && response.deleted) {
                    Timber.d("Delete Stream Successful")
                } else {
                    Timber.d("Delete Stream Failure")
                }
                _screenEvent.value = StreamViewEvent.OnDeleteStream
            }
        }
    }
}