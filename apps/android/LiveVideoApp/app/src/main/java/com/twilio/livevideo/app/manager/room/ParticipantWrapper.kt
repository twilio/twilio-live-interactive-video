package com.twilio.livevideo.app.manager.room

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.twilio.livevideo.app.custom.BaseLifeCycleComponent
import com.twilio.video.NetworkQualityLevel
import com.twilio.video.Participant
import com.twilio.video.VideoTrack

abstract class ParticipantWrapper<T : VideoTrack, V : Participant> : BaseLifeCycleComponent() {

    val sid: String?
        get() = participant?.sid

    val identity: String?
        get() = participant?.identity

    var videoTrack: T? = null

    var isDominantSpeaker: Boolean = false

    var isAudioMuted = false

    var isVideoMuted = false

    var isHost: Boolean = false

    var networkQualityLevel: NetworkQualityLevel = NetworkQualityLevel.NETWORK_QUALITY_LEVEL_UNKNOWN

    open var participant: V? = null

    protected val _onStateEvent: MutableLiveData<RoomViewEvent?> =
        MutableLiveData<RoomViewEvent?>(null)
    val onStateEvent: LiveData<RoomViewEvent?>
        get() {
            val event = _onStateEvent
            _onStateEvent.value = null
            return event
        }

}

data class ParticipantStream(var participantWrapper: ParticipantWrapper<out VideoTrack, out Participant>)