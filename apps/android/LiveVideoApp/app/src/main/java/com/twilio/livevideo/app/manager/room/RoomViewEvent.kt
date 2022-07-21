package com.twilio.livevideo.app.manager.room

import com.twilio.livevideo.app.repository.model.ErrorResponse
import com.twilio.video.NetworkQualityLevel

sealed class RoomViewEvent {

    data class OnConnected(val participants: List<ParticipantStream>, val roomName: String) : RoomViewEvent()
    data class OnDisconnect(val error: ErrorResponse?) : RoomViewEvent()
    data class OnRemoteParticipantConnected(val participant: ParticipantStream) : RoomViewEvent()
    data class OnRemoteParticipantDisconnected(val participant: ParticipantStream) : RoomViewEvent()
    data class OnRemoteParticipantUpdate(val participant: ParticipantStream) : RoomViewEvent()
    data class OnDominantSpeakerUpdate(val participant: ParticipantStream?) : RoomViewEvent()
    data class OnNetworkQualityLevelChange(val participant: ParticipantStream, val networkQualityLevel: NetworkQualityLevel) : RoomViewEvent()

}