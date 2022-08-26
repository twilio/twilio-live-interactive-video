package com.twilio.livevideo.app.manager.room

import android.content.Context
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.twilio.livevideo.app.custom.BaseLifeCycleComponent
import com.twilio.livevideo.app.repository.model.ErrorResponse
import com.twilio.video.BandwidthProfileMode
import com.twilio.video.OpusCodec
import com.twilio.video.RemoteParticipant
import com.twilio.video.Room
import com.twilio.video.TrackPriority
import com.twilio.video.TwilioException
import com.twilio.video.Vp8Codec
import com.twilio.video.ktx.ConnectOptionsBuilder
import com.twilio.video.ktx.Video
import com.twilio.video.ktx.createBandwidthProfileOptions
import timber.log.Timber
import javax.inject.Inject

class RoomManager @Inject constructor(
    private val context: Context?,
    val localParticipantWrapper: LocalParticipantWrapper
) : BaseLifeCycleComponent(),
    Room.Listener {

    private val _onStateEvent: MutableLiveData<RoomViewEvent?> =
        MutableLiveData<RoomViewEvent?>(null)
    val onStateEvent: LiveData<RoomViewEvent?>
        get() {
            val event = _onStateEvent
            _onStateEvent.value = null
            return event
        }

    private var lifecycleOwner: LifecycleOwner? = null
    private var room: Room? = null

    fun connect(
        lifecycleOwner: LifecycleOwner,
        roomName: String,
        accessToken: String,
        isHost: Boolean = false
    ) {
        this.lifecycleOwner = lifecycleOwner
        init(lifecycleOwner.lifecycle)
        localParticipantWrapper.init(lifecycleOwner.lifecycle)
        localParticipantWrapper.setupLocalTracks()
        localParticipantWrapper.isHost = isHost
        room = context?.let {
            val connectOptions: ConnectOptionsBuilder = {
                this.roomName(roomName)
                this.audioTracks(listOf(localParticipantWrapper.localAudioTrack))
                this.videoTracks(listOf(localParticipantWrapper.localVideoTrack))
                this.enableDominantSpeaker(true)
                this.bandwidthProfile(createBandwidthProfileOptions {
                    this.mode(BandwidthProfileMode.GRID)
                    this.dominantSpeakerPriority(TrackPriority.HIGH)
                })
                this.preferVideoCodecs(listOf(Vp8Codec(true)))
                this.preferAudioCodecs(listOf(OpusCodec()))
            }
            Video.connect(it, accessToken, this, connectOptions)
        }
    }

    fun disconnect() {
        disconnect(null, false)
    }

    private fun disconnect(disconnectionType: RoomDisconnectionType?, notifyStateEvent: Boolean = true) {
        cleanUp()
        if (notifyStateEvent)
            _onStateEvent.value = RoomViewEvent.OnDisconnected(disconnectionType)
    }

    private fun handleError(errorResponse: ErrorResponse?) {
        cleanUp()
        _onStateEvent.value = RoomViewEvent.OnError(errorResponse)
    }

    private fun cleanUp() {
        localParticipantWrapper.isCameraOn = false
        localParticipantWrapper.isMicOn = false
        room?.disconnect()
        room = null
    }

    override fun onConnected(room: Room) {
        Timber.i("onConnected -> room sid: %s", room.sid)

        room.localParticipant?.let { localParticipant ->
            val list = mutableListOf<ParticipantStream>()
            localParticipantWrapper.localParticipant = localParticipant
            list.add(localParticipantWrapper)

            room.remoteParticipants.filter {
                !it.isVideoComposer()
            }.forEach {
                val newRemoteParticipant = RemoteParticipantWrapper(it)
                lifecycleOwner?.lifecycle?.apply { newRemoteParticipant.init(this) }
                newRemoteParticipant.isLocalHost = localParticipantWrapper.isHost
                list.add(newRemoteParticipant)
            }
            _onStateEvent.value = RoomViewEvent.OnConnected(list, room.name)
        }
        this.room = room
    }

    override fun onConnectFailure(room: Room, twilioException: TwilioException) {
        Timber.i("onConnectFailure -> room sid: %s", room.sid)
        this.localParticipantWrapper.participant = null
        handleError(ErrorResponse(twilioException.message ?: "Error", twilioException.explanation ?: "onConnectFailure"))
    }

    override fun onReconnecting(room: Room, twilioException: TwilioException) {
        Timber.i("onReconnecting -> room sid: %s", room.sid)
    }

    override fun onReconnected(room: Room) {
        Timber.i("onReconnected -> room sid: %s", room.sid)
    }

    override fun onDisconnected(room: Room, twilioException: TwilioException?) {
        Timber.i("onDisconnected -> room sid: ${room.sid}")
        Timber.i("onDisconnected -> room exception message: ${twilioException?.message}")
        Timber.i("onDisconnected -> room exception code: ${twilioException?.code}")
        Timber.i("onDisconnected -> Lifecycle state: ${lifecycleOwner?.lifecycle?.currentState}")

        // This condition is most when the room is disconnected by the local participant. In example, clicking the UI to disconnect the room.
        if (this.room == null) return

        twilioException?.code?.apply {
            when (this) {
                TwilioException.ROOM_ROOM_COMPLETED_EXCEPTION -> disconnect(RoomDisconnectionType.StreamEndedByHost)
                TwilioException.PARTICIPANT_NOT_FOUND_EXCEPTION -> disconnect(RoomDisconnectionType.SpeakerMovedToViewersByHost)
            }
        } ?: run {
            disconnect(RoomDisconnectionType.SpeakerMovedToViewersByHost)
        }
    }

    override fun onParticipantConnected(room: Room, remoteParticipant: RemoteParticipant) {
        Timber.i("onParticipantConnected -> room sid: %s", room.sid)
        if (remoteParticipant.isVideoComposer()) return
        val newParticipant = RemoteParticipantWrapper(remoteParticipant)
        lifecycleOwner?.lifecycle?.apply { newParticipant.init(this) }
        newParticipant.isLocalHost = localParticipantWrapper.isHost
        _onStateEvent.value = RoomViewEvent.OnRemoteParticipantConnected(newParticipant)
    }

    override fun onParticipantDisconnected(
        room: Room,
        remoteParticipant: RemoteParticipant
    ) {
        Timber.i("onParticipantDisconnected -> room sid: %s", room.sid)
        _onStateEvent.value = RoomViewEvent.OnRemoteParticipantDisconnected(remoteParticipant.identity)
    }

    override fun onRecordingStarted(room: Room) {
        Timber.i("onRecordingStarted -> room sid: %s", room.sid)
    }

    override fun onRecordingStopped(room: Room) {
        Timber.i("onRecordingStopped -> room sid: %s", room.sid)
    }

    override fun onDominantSpeakerChanged(room: Room, remoteParticipant: RemoteParticipant?) {
        super.onDominantSpeakerChanged(room, remoteParticipant)
        Timber.i("onDominantSpeakerChanged -> room sid: %s", room.sid)
        _onStateEvent.value = RoomViewEvent.OnDominantSpeakerChanged(remoteParticipant?.identity)
    }

    override fun onDestroy(owner: LifecycleOwner) {
        Timber.i("onDestroyCallback")
    }

    private fun RemoteParticipant.isVideoComposer(): Boolean =
        identity.contains("video-composer", true)
}