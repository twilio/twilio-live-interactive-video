package com.twilio.livevideo.app.manager.room

import androidx.lifecycle.LifecycleOwner
import com.twilio.video.RemoteAudioTrack
import com.twilio.video.RemoteAudioTrackPublication
import com.twilio.video.RemoteDataTrack
import com.twilio.video.RemoteDataTrackPublication
import com.twilio.video.RemoteParticipant
import com.twilio.video.RemoteVideoTrack
import com.twilio.video.RemoteVideoTrackPublication
import com.twilio.video.TwilioException
import timber.log.Timber

data class RemoteParticipantWrapper constructor(
    private val remoteParticipantParam: RemoteParticipant
) : ParticipantStream(), RemoteParticipant.Listener {

    var remoteParticipant: RemoteParticipant?
        get() = if (super.participant is RemoteParticipant) super.participant as RemoteParticipant else null
        set(value) {
            value?.setListener(this)
            super.participant = value
        }

    var remoteVideoTrack: RemoteVideoTrack?
        get() = if (super.videoTrack is RemoteVideoTrack) super.videoTrack as RemoteVideoTrack else null
        set(value) {
            super.videoTrack = value
        }

    private var isAudioTrackSubscribed: Boolean = false
        set(value) {
            field = value
            isMicOn = value && isAudioTrackEnabled
        }

    private var isAudioTrackEnabled: Boolean = true
        set(value) {
            field = value
            isMicOn = value && isAudioTrackSubscribed
        }

    init {
        remoteParticipant = remoteParticipantParam
    }

    override fun onDestroy(owner: LifecycleOwner) {
        Timber.d("onDestroy")
    }

    override fun onAudioTrackPublished(
        remoteParticipant: RemoteParticipant,
        remoteAudioTrackPublication: RemoteAudioTrackPublication
    ) {
        Timber.d("onAudioTrackPublished")
    }

    override fun onAudioTrackUnpublished(
        remoteParticipant: RemoteParticipant,
        remoteAudioTrackPublication: RemoteAudioTrackPublication
    ) {
        Timber.d("onAudioTrackUnpublished")
    }

    override fun onAudioTrackSubscribed(
        remoteParticipant: RemoteParticipant,
        remoteAudioTrackPublication: RemoteAudioTrackPublication,
        remoteAudioTrack: RemoteAudioTrack
    ) {
        Timber.d("onAudioTrackSubscribed")
        //Remote Audio Subscribed
        isAudioTrackSubscribed = true
    }

    override fun onAudioTrackUnsubscribed(
        remoteParticipant: RemoteParticipant,
        remoteAudioTrackPublication: RemoteAudioTrackPublication,
        remoteAudioTrack: RemoteAudioTrack
    ) {
        Timber.d("onAudioTrackUnsubscribed")
        //Remote Audio Unsubscribed
        isAudioTrackSubscribed = false
    }

    override fun onAudioTrackSubscriptionFailed(
        remoteParticipant: RemoteParticipant,
        remoteAudioTrackPublication: RemoteAudioTrackPublication,
        twilioException: TwilioException
    ) {
        Timber.d("onAudioTrackSubscriptionFailed")
    }

    override fun onVideoTrackPublished(
        remoteParticipant: RemoteParticipant,
        remoteVideoTrackPublication: RemoteVideoTrackPublication
    ) {
        Timber.d("onVideoTrackPublished")
    }

    override fun onVideoTrackUnpublished(
        remoteParticipant: RemoteParticipant,
        remoteVideoTrackPublication: RemoteVideoTrackPublication
    ) {
        Timber.d("onVideoTrackUnpublished")
    }

    override fun onVideoTrackSubscribed(
        remoteParticipant: RemoteParticipant,
        remoteVideoTrackPublication: RemoteVideoTrackPublication,
        remoteVideoTrack: RemoteVideoTrack
    ) {
        Timber.d("onVideoTrackSubscribed")
        this.remoteVideoTrack = remoteVideoTrack
        isCameraOn = true
    }

    override fun onVideoTrackSubscriptionFailed(
        remoteParticipant: RemoteParticipant,
        remoteVideoTrackPublication: RemoteVideoTrackPublication,
        twilioException: TwilioException
    ) {
        Timber.d("onVideoTrackSubscriptionFailed")
    }

    override fun onVideoTrackUnsubscribed(
        remoteParticipant: RemoteParticipant,
        remoteVideoTrackPublication: RemoteVideoTrackPublication,
        remoteVideoTrack: RemoteVideoTrack
    ) {
        Timber.d("onVideoTrackUnsubscribed")
        this.remoteVideoTrack = null
        isCameraOn = false
    }

    override fun onDataTrackPublished(
        remoteParticipant: RemoteParticipant,
        remoteDataTrackPublication: RemoteDataTrackPublication
    ) {
        Timber.d("onDataTrackPublished")
    }

    override fun onDataTrackUnpublished(
        remoteParticipant: RemoteParticipant,
        remoteDataTrackPublication: RemoteDataTrackPublication
    ) {
        Timber.d("onDataTrackUnpublished")
    }

    override fun onDataTrackSubscribed(
        remoteParticipant: RemoteParticipant,
        remoteDataTrackPublication: RemoteDataTrackPublication,
        remoteDataTrack: RemoteDataTrack
    ) {
        Timber.d("onDataTrackSubscribed")
    }

    override fun onDataTrackSubscriptionFailed(
        remoteParticipant: RemoteParticipant,
        remoteDataTrackPublication: RemoteDataTrackPublication,
        twilioException: TwilioException
    ) {
        Timber.d("onDataTrackSubscriptionFailed")
    }

    override fun onDataTrackUnsubscribed(
        remoteParticipant: RemoteParticipant,
        remoteDataTrackPublication: RemoteDataTrackPublication,
        remoteDataTrack: RemoteDataTrack
    ) {
        Timber.d("onDataTrackUnsubscribed")
    }

    override fun onAudioTrackEnabled(
        remoteParticipant: RemoteParticipant,
        remoteAudioTrackPublication: RemoteAudioTrackPublication
    ) {
        Timber.d("onAudioTrackEnabled")
        //Remote Audio Enabled
        isAudioTrackEnabled = true
    }

    override fun onAudioTrackDisabled(
        remoteParticipant: RemoteParticipant,
        remoteAudioTrackPublication: RemoteAudioTrackPublication
    ) {
        Timber.d("onAudioTrackDisabled")
        //Remote Audio Disabled
        isAudioTrackEnabled = false
    }

    override fun onVideoTrackEnabled(
        remoteParticipant: RemoteParticipant,
        remoteVideoTrackPublication: RemoteVideoTrackPublication
    ) {
        Timber.d("onVideoTrackEnabled")
    }

    override fun onVideoTrackDisabled(
        remoteParticipant: RemoteParticipant,
        remoteVideoTrackPublication: RemoteVideoTrackPublication
    ) {
        Timber.d("onVideoTrackDisabled")
    }
}