package com.twilio.livevideo.app.manager.room

import android.content.Context
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import com.twilio.livevideo.app.R
import com.twilio.video.LocalAudioTrack
import com.twilio.video.LocalAudioTrackPublication
import com.twilio.video.LocalDataTrack
import com.twilio.video.LocalDataTrackPublication
import com.twilio.video.LocalParticipant
import com.twilio.video.LocalTrackPublicationOptions
import com.twilio.video.LocalVideoTrack
import com.twilio.video.LocalVideoTrackPublication
import com.twilio.video.TrackPriority
import com.twilio.video.TwilioException
import com.twilio.video.ktx.createLocalAudioTrack
import timber.log.Timber
import javax.inject.Inject

data class LocalParticipantWrapper @Inject constructor(private val context: Context?) :
    ParticipantStream(), LocalParticipant.Listener {

    internal var localAudioTrack: LocalAudioTrack? = null

    private var cameraCapturer: CameraCapturerCompat? = null

    var localParticipant: LocalParticipant?
        get() = if (super.participant is LocalParticipant) super.participant as LocalParticipant else null
        set(value) {
            value?.setListener(this)
            super.participant = value
        }

    var localVideoTrack: LocalVideoTrack?
        get() = if (super.videoTrack is LocalVideoTrack) super.videoTrack as LocalVideoTrack else null
        set(value) {
            super.videoTrack = value
        }

    private val localVideoTrackNames: MutableMap<String, String> = HashMap()

    override fun init(lifecycle: Lifecycle) {
        super.init(lifecycle)
        setupLocalTracks()
    }

    override fun onResume(owner: LifecycleOwner) {
        super.onResume(owner)
        Timber.i("onResumeCallback $identity")
        if (isMicOn) setupLocalAudioTrack()
        if (isCameraOn) setupLocalVideoTrack()
    }

    override fun onPause(owner: LifecycleOwner) {
        super.onPause(owner)
        Timber.i("onPauseCallback $identity")
        removeCameraTrack()
    }

    fun toggleLocalAudio(value: Boolean = isMicOn) {
        if (value) {
            setupLocalAudioTrack()
        } else {
            removeAudioTrack(value)
        }
    }

    fun toggleLocalVideo(value: Boolean = isCameraOn) {
        if (value) {
            setupLocalVideoTrack()
        } else {
            removeCameraTrack(value)
        }
    }

    fun setupLocalTracks() {
        setupLocalVideoTrack()
        setupLocalAudioTrack()
        isMicOn = true
        isCameraOn = true
    }

    private fun setupLocalAudioTrack() {
        if (localAudioTrack == null && context != null) {
            localAudioTrack = createLocalAudioTrack(context, true, MICROPHONE_TRACK_NAME)
            localAudioTrack?.also {
                publishAudioTrack(it)
            } ?: Timber.e(RuntimeException(), "Failed to create local audio track")
        }
    }

    private fun publishAudioTrack(localAudioTrack: LocalAudioTrack? = this.localAudioTrack) {
        localAudioTrack?.let {
            localParticipant?.publishTrack(it)?.also { isMicOn = true }
        }
    }

    private fun setupLocalVideoTrack() {
        context?.let {
            cameraCapturer = CameraCapturerCompat.newInstance(it)

            cameraCapturer?.let { capturer ->
                LocalVideoTrack.create(it, true, capturer, null, CAMERA_TRACK_NAME)
            }?.apply {
                localVideoTrackNames[name] = context.getString(R.string.camera_video_track)
                localVideoTrack = this
                publishCameraTrack(this)
            }
        }
    }

    private fun publishCameraTrack(localVideoTrack: LocalVideoTrack? = this.localVideoTrack) {
        localVideoTrack?.let {
            localParticipant?.publishTrack(it, LocalTrackPublicationOptions(TrackPriority.LOW))?.also {
                isCameraOn = true
            }
        }
    }

    private fun unPublishTrack(localVideoTrack: LocalVideoTrack?) = localVideoTrack?.let { localParticipant?.unpublishTrack(it) }

    private fun unPublishTrack(localAudioTrack: LocalAudioTrack?) = localAudioTrack?.let { localParticipant?.unpublishTrack(it) }

    private fun removeCameraTrack(isCameraOn: Boolean? = null) {
        localVideoTrack?.let { cameraVideoTrack ->
            unPublishTrack(cameraVideoTrack)
            localVideoTrackNames.remove(cameraVideoTrack.name)
            cameraVideoTrack.release()
            localVideoTrack = null
            isCameraOn?.also {
                this.isCameraOn = it
            }
        }
    }

    private fun removeAudioTrack(isMicOn: Boolean = this.isMicOn) {
        localAudioTrack?.let { localAudioTrack ->
            unPublishTrack(localAudioTrack)
            localAudioTrack.release()
            this.localAudioTrack = null
            this.isMicOn = isMicOn
        }
    }

    override fun onAudioTrackPublished(
        localParticipant: LocalParticipant,
        localAudioTrackPublication: LocalAudioTrackPublication
    ) {
        Timber.d("onAudioTrackPublished")
    }

    override fun onAudioTrackPublicationFailed(
        localParticipant: LocalParticipant,
        localAudioTrack: LocalAudioTrack,
        twilioException: TwilioException
    ) {
        Timber.d("onAudioTrackPublicationFailed ${twilioException.message}")
    }

    override fun onVideoTrackPublished(
        localParticipant: LocalParticipant,
        localVideoTrackPublication: LocalVideoTrackPublication
    ) {
        Timber.d("onVideoTrackPublished")
    }

    override fun onVideoTrackPublicationFailed(
        localParticipant: LocalParticipant,
        localVideoTrack: LocalVideoTrack,
        twilioException: TwilioException
    ) {
        Timber.d("onVideoTrackPublicationFailed ${twilioException.message}")
    }

    override fun onDataTrackPublished(
        localParticipant: LocalParticipant,
        localDataTrackPublication: LocalDataTrackPublication
    ) {
        Timber.d("onDataTrackPublished")
    }

    override fun onDataTrackPublicationFailed(
        localParticipant: LocalParticipant,
        localDataTrack: LocalDataTrack,
        twilioException: TwilioException
    ) {
        Timber.d("onDataTrackPublicationFailed ${twilioException.message}")
    }

    companion object {
        private const val CAMERA_TRACK_NAME = "camera"
        private const val MICROPHONE_TRACK_NAME = "microphone"
    }
}