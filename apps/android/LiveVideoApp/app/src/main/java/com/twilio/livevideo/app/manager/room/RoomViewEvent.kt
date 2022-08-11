package com.twilio.livevideo.app.manager.room

import com.twilio.livevideo.app.repository.model.ErrorResponse

sealed class RoomViewEvent {

    data class OnConnected(val participants: List<ParticipantStream>, val roomName: String) : RoomViewEvent()
    data class OnDisconnected(val disconnectionType: RoomDisconnectionType?) : RoomViewEvent()
    data class OnError(val error: ErrorResponse?) : RoomViewEvent()
    data class OnDominantSpeakerChanged(val participants: List<ParticipantStream>) : RoomViewEvent()
    data class OnRemoteParticipantConnected(val participants: List<ParticipantStream>) : RoomViewEvent()
    data class OnRemoteParticipantDisconnected(val participants: List<ParticipantStream>) : RoomViewEvent()
    data class OnRemoteParticipantOnClickMenu(val participant: RemoteParticipantWrapper) : RoomViewEvent()

}

sealed class RoomDisconnectionType {
    object StreamEndedByHost : RoomDisconnectionType()
}