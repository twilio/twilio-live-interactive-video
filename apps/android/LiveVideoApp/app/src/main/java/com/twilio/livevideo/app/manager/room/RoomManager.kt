package com.twilio.livevideo.app.manager.room

import android.content.Context
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Observer
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
    private val localParticipantWrapper: LocalParticipantWrapper
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

    private val participantsObserver: Observer<in RoomViewEvent?> = Observer {
        it?.apply {
            this@RoomManager._onStateEvent.value = this
        }
    }

    private var lifecycleOwner: LifecycleOwner? = null
    private var room: Room? = null
    private var participants: MutableList<ParticipantStream>? = null

    fun connect(
        lifecycleOwner: LifecycleOwner,
        roomName: String,
        accessToken: String,
        isHost: Boolean = false
    ) {
        this.lifecycleOwner = lifecycleOwner
        init(lifecycleOwner.lifecycle)
        localParticipantWrapper.init(lifecycleOwner.lifecycle)
        localParticipantWrapper.isHost = isHost
        registerLocalParticipantManagerObserver(lifecycleOwner)
        room = context?.let {
            val connectOptions: ConnectOptionsBuilder = {
                this.roomName(roomName)
                this.audioTracks(listOf(localParticipantWrapper.localAudioTrack))
                this.videoTracks(listOf(localParticipantWrapper.videoTrack))
                this.enableDominantSpeaker(true)
                this.bandwidthProfile(createBandwidthProfileOptions {
                    this.mode(BandwidthProfileMode.GRID)
                    this.dominantSpeakerPriority(TrackPriority.HIGH)
                })
                preferVideoCodecs(listOf(Vp8Codec()))
                preferAudioCodecs(listOf(OpusCodec()))
            }
            Video.connect(it, accessToken, this, connectOptions)
        }
    }

    fun disconnect() {
        cleanUp()
        _onStateEvent.value = RoomViewEvent.OnDisconnect(null)
    }

    private fun handleError(errorResponse: ErrorResponse) {
        cleanUp()
        _onStateEvent.value = RoomViewEvent.OnDisconnect(errorResponse)
    }

    private fun cleanUp() {
        room?.disconnect()
        room = null
        localParticipantWrapper.participant = null
        participants?.clear()
    }

    private fun registerLocalParticipantManagerObserver(lifecycleOwner: LifecycleOwner) {
        localParticipantWrapper.onStateEvent.observe(lifecycleOwner, participantsObserver)
    }

    private fun registerRemoteParticipantManagerObserver(lifecycleOwner: LifecycleOwner?, remoteParticipantWrapper: RemoteParticipantWrapper) {
        lifecycleOwner?.apply {
            remoteParticipantWrapper.onStateEvent.observe(this, participantsObserver)
        }
    }

    override fun onConnected(room: Room) {
        Timber.i("onConnected -> room sid: %s", room.sid)

        room.localParticipant?.let { localParticipant ->
            participants = mutableListOf<ParticipantStream>().let { list ->
                localParticipantWrapper.participant = localParticipant
                list.add(ParticipantStream(localParticipantWrapper))

                room.remoteParticipants.filter {
                    !it.isVideoComposer()
                }.forEach {
                    val newRemoteParticipant = RemoteParticipantWrapper(it)
                    registerRemoteParticipantManagerObserver(lifecycleOwner, newRemoteParticipant)
                    list.add(ParticipantStream(newRemoteParticipant))
                }
                _onStateEvent.value = RoomViewEvent.OnConnected(list, room.name)
                list
            }
        }
        this.room = room
    }

    override fun onConnectFailure(room: Room, twilioException: TwilioException) {
        this.localParticipantWrapper.participant = null
        handleError(ErrorResponse(twilioException.message ?: "Error", twilioException.explanation ?: "onConnectFailure"))
    }

    override fun onReconnecting(room: Room, twilioException: TwilioException) {

    }

    override fun onReconnected(room: Room) {

    }

    override fun onDisconnected(room: Room, twilioException: TwilioException?) {

    }

    override fun onParticipantConnected(room: Room, remoteParticipant: RemoteParticipant) {
        if (remoteParticipant.isVideoComposer()) return
        val newParticipant = ParticipantStream(RemoteParticipantWrapper(remoteParticipant))
        participants?.add(newParticipant)
        _onStateEvent.value = RoomViewEvent.OnRemoteParticipantConnected(newParticipant)
    }

    override fun onParticipantDisconnected(
        room: Room,
        remoteParticipant: RemoteParticipant
    ) {
        participants?.first { it.participantWrapper.participant?.identity == remoteParticipant.identity }?.apply {
            _onStateEvent.value = RoomViewEvent.OnRemoteParticipantDisconnected(this)
        }
    }

    override fun onRecordingStarted(room: Room) {

    }

    override fun onRecordingStopped(room: Room) {

    }

    override fun onDominantSpeakerChanged(room: Room, remoteParticipant: RemoteParticipant?) {
        super.onDominantSpeakerChanged(room, remoteParticipant)
        participants?.first { it.participantWrapper.isDominantSpeaker }?.apply { this.participantWrapper.isDominantSpeaker = false }
        participants?.first { it.participantWrapper.identity == remoteParticipant?.identity }?.apply {
            this.participantWrapper.isDominantSpeaker = true
            _onStateEvent.value = RoomViewEvent.OnDominantSpeakerUpdate(this)
        }
    }

    private fun RemoteParticipant.isVideoComposer(): Boolean =
        identity.contains("video-composer", true)
}