package com.twilio.livevideo.app.manager.room

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

    var isMuted: Boolean = false

    var isHost: Boolean = false

    var networkQualityLevel: NetworkQualityLevel = NetworkQualityLevel.NETWORK_QUALITY_LEVEL_UNKNOWN

    open var participant: V? = null

}

data class ParticipantStream(var participantWrapper: ParticipantWrapper<out VideoTrack, out Participant>)