package com.twilio.livevideo.app.manager.room

import com.twilio.video.NetworkQualityLevel
import com.twilio.video.RemoteAudioTrack
import com.twilio.video.RemoteAudioTrackPublication
import com.twilio.video.RemoteDataTrack
import com.twilio.video.RemoteDataTrackPublication
import com.twilio.video.RemoteParticipant
import com.twilio.video.RemoteVideoTrack
import com.twilio.video.RemoteVideoTrackPublication
import com.twilio.video.TwilioException

class RemoteParticipantWrapper constructor(participant: RemoteParticipant?) : ParticipantWrapper<RemoteVideoTrack, RemoteParticipant>(),
    RemoteParticipant.Listener {

    override var participant: RemoteParticipant? = participant
        set(value) {
            value?.setListener(this)
            field = value
        }

    override fun onAudioTrackPublished(
        remoteParticipant: RemoteParticipant,
        remoteAudioTrackPublication: RemoteAudioTrackPublication
    ) {
        _onStateEvent.value = RoomViewEvent.OnRemoteParticipantUpdate(ParticipantStream(this))
    }

    override fun onAudioTrackUnpublished(
        remoteParticipant: RemoteParticipant,
        remoteAudioTrackPublication: RemoteAudioTrackPublication
    ) {
        _onStateEvent.value = RoomViewEvent.OnRemoteParticipantUpdate(ParticipantStream(this))
    }

    override fun onAudioTrackSubscribed(
        remoteParticipant: RemoteParticipant,
        remoteAudioTrackPublication: RemoteAudioTrackPublication,
        remoteAudioTrack: RemoteAudioTrack
    ) {
        _onStateEvent.value = RoomViewEvent.OnRemoteParticipantUpdate(ParticipantStream(this))
    }

    override fun onAudioTrackSubscriptionFailed(
        remoteParticipant: RemoteParticipant,
        remoteAudioTrackPublication: RemoteAudioTrackPublication,
        twilioException: TwilioException
    ) {
        _onStateEvent.value = RoomViewEvent.OnRemoteParticipantUpdate(ParticipantStream(this))
    }

    override fun onAudioTrackUnsubscribed(
        remoteParticipant: RemoteParticipant,
        remoteAudioTrackPublication: RemoteAudioTrackPublication,
        remoteAudioTrack: RemoteAudioTrack
    ) {
        _onStateEvent.value = RoomViewEvent.OnRemoteParticipantUpdate(ParticipantStream(this))
    }

    override fun onVideoTrackPublished(
        remoteParticipant: RemoteParticipant,
        remoteVideoTrackPublication: RemoteVideoTrackPublication
    ) {
        _onStateEvent.value = RoomViewEvent.OnRemoteParticipantUpdate(ParticipantStream(this))
    }

    override fun onVideoTrackUnpublished(
        remoteParticipant: RemoteParticipant,
        remoteVideoTrackPublication: RemoteVideoTrackPublication
    ) {
        _onStateEvent.value = RoomViewEvent.OnRemoteParticipantUpdate(ParticipantStream(this))
    }

    override fun onVideoTrackSubscribed(
        remoteParticipant: RemoteParticipant,
        remoteVideoTrackPublication: RemoteVideoTrackPublication,
        remoteVideoTrack: RemoteVideoTrack
    ) {
        _onStateEvent.value = RoomViewEvent.OnRemoteParticipantUpdate(ParticipantStream(this))
    }

    override fun onVideoTrackSubscriptionFailed(
        remoteParticipant: RemoteParticipant,
        remoteVideoTrackPublication: RemoteVideoTrackPublication,
        twilioException: TwilioException
    ) {
        _onStateEvent.value = RoomViewEvent.OnRemoteParticipantUpdate(ParticipantStream(this))
    }

    override fun onVideoTrackUnsubscribed(
        remoteParticipant: RemoteParticipant,
        remoteVideoTrackPublication: RemoteVideoTrackPublication,
        remoteVideoTrack: RemoteVideoTrack
    ) {
        _onStateEvent.value = RoomViewEvent.OnRemoteParticipantUpdate(ParticipantStream(this))
    }

    override fun onDataTrackPublished(
        remoteParticipant: RemoteParticipant,
        remoteDataTrackPublication: RemoteDataTrackPublication
    ) {
        _onStateEvent.value = RoomViewEvent.OnRemoteParticipantUpdate(ParticipantStream(this))
    }

    override fun onDataTrackUnpublished(
        remoteParticipant: RemoteParticipant,
        remoteDataTrackPublication: RemoteDataTrackPublication
    ) {
        _onStateEvent.value = RoomViewEvent.OnRemoteParticipantUpdate(ParticipantStream(this))
    }

    override fun onDataTrackSubscribed(
        remoteParticipant: RemoteParticipant,
        remoteDataTrackPublication: RemoteDataTrackPublication,
        remoteDataTrack: RemoteDataTrack
    ) {
        _onStateEvent.value = RoomViewEvent.OnRemoteParticipantUpdate(ParticipantStream(this))
    }

    override fun onDataTrackSubscriptionFailed(
        remoteParticipant: RemoteParticipant,
        remoteDataTrackPublication: RemoteDataTrackPublication,
        twilioException: TwilioException
    ) {
        _onStateEvent.value = RoomViewEvent.OnRemoteParticipantUpdate(ParticipantStream(this))
    }

    override fun onDataTrackUnsubscribed(
        remoteParticipant: RemoteParticipant,
        remoteDataTrackPublication: RemoteDataTrackPublication,
        remoteDataTrack: RemoteDataTrack
    ) {
        _onStateEvent.value = RoomViewEvent.OnRemoteParticipantUpdate(ParticipantStream(this))
    }

    override fun onAudioTrackEnabled(
        remoteParticipant: RemoteParticipant,
        remoteAudioTrackPublication: RemoteAudioTrackPublication
    ) {
        _onStateEvent.value = RoomViewEvent.OnRemoteParticipantUpdate(ParticipantStream(this))
    }

    override fun onAudioTrackDisabled(
        remoteParticipant: RemoteParticipant,
        remoteAudioTrackPublication: RemoteAudioTrackPublication
    ) {
        _onStateEvent.value = RoomViewEvent.OnRemoteParticipantUpdate(ParticipantStream(this))
    }

    override fun onVideoTrackEnabled(
        remoteParticipant: RemoteParticipant,
        remoteVideoTrackPublication: RemoteVideoTrackPublication
    ) {
        _onStateEvent.value = RoomViewEvent.OnRemoteParticipantUpdate(ParticipantStream(this))
    }

    override fun onVideoTrackDisabled(
        remoteParticipant: RemoteParticipant,
        remoteVideoTrackPublication: RemoteVideoTrackPublication
    ) {
        _onStateEvent.value = RoomViewEvent.OnRemoteParticipantUpdate(ParticipantStream(this))
    }

    override fun onNetworkQualityLevelChanged(remoteParticipant: RemoteParticipant, networkQualityLevel: NetworkQualityLevel) {
        _onStateEvent.value = RoomViewEvent.OnNetworkQualityLevelChange(ParticipantStream(this), networkQualityLevel)
    }
}