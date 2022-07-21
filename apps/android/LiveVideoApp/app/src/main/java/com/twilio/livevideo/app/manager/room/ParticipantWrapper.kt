package com.twilio.livevideo.app.manager.room

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.twilio.livevideo.app.custom.BaseLifeCycleComponent
import com.twilio.video.Participant
import com.twilio.video.VideoTrack

abstract class ParticipantWrapper<T : VideoTrack, V : Participant> : BaseLifeCycleComponent() {

    val sid: String?
        get() = _viewState.value?.sid

    val identity: String?
        get() = _viewState.value?.identity

    var videoTrack: T?
        get() = _viewState.value?.videoTrack
        set(value) {
            _viewState.value?.videoTrack = value
        }

    var isDominantSpeaker: Boolean
        get() = _viewState.value?.isDominantSpeaker ?: false
        set(value) {
            _viewState.value?.isDominantSpeaker = value
        }

    var isAudioMuted: Boolean
        get() = _viewState.value?.isAudioMuted ?: false
        set(value) {
            _viewState.value?.isAudioMuted = value
        }

    var isVideoMuted: Boolean
        get() = _viewState.value?.isVideoMuted ?: false
        set(value) {
            _viewState.value?.isVideoMuted = value
        }

    var isHost: Boolean
        get() = _viewState.value?.isHost ?: false
        set(value) {
            _viewState.value?.isHost = value
        }

    open var participant: V?
        get() = _viewState.value?.participant
        set(value) {
            _viewState.value?.participant = value
        }

    private val _viewState: MutableLiveData<ParticipantViewState<T, V>> = MutableLiveData(ParticipantViewState())
    val viewState: LiveData<ParticipantViewState<T, V>>
        get() = _viewState
}

data class ParticipantViewState<T : VideoTrack, V : Participant>(
    var participant: V? = null,

    val sid: String? = participant?.sid,

    val identity: String? = participant?.identity,

    var videoTrack: T? = null,

    var isDominantSpeaker: Boolean = false,

    var isAudioMuted: Boolean = false,

    var isVideoMuted: Boolean = false,

    var isHost: Boolean = false,
)

data class ParticipantStream(var wrapper: ParticipantWrapper<out VideoTrack, out Participant>)