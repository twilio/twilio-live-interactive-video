package com.twilio.livevideo.app.manager.room

import android.content.Context
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

class LocalParticipantWrapper @Inject constructor(private val context: Context?) :
    ParticipantWrapper(), LocalParticipant.Listener {

    internal var localAudioTrack: LocalAudioTrack? = null

    private var cameraCapturer: CameraCapturerCompat? = null

    var localParticipant: LocalParticipant?
        get() = super.participant as LocalParticipant
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

    override fun onParticipantClick() {
        //No OnClick event requirement for LocalParticipant.
    }

    override fun onResume(owner: LifecycleOwner) {
        super.onResume(owner)
        if (isMicOn) setupLocalAudioTrack()
        if (isCameraOn) setupLocalVideoTrack()
    }

    override fun onPause(owner: LifecycleOwner) {
        super.onPause(owner)
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

    fun publishLocalTracks() {
        setupLocalAudioTrack()
        setupLocalVideoTrack()
    }

    private fun setupLocalAudioTrack() {
        if (localAudioTrack == null && context != null) {
            localAudioTrack = createLocalAudioTrack(context, true, MICROPHONE_TRACK_NAME)
            localAudioTrack?.let {
                isMicOn = true
                publishAudioTrack(it)
            }
                ?: Timber.e(RuntimeException(), "Failed to create local audio track")
        }
    }

    private fun setupLocalVideoTrack() {
        context?.let {
            cameraCapturer = CameraCapturerCompat.newInstance(it)

            cameraCapturer?.let { capturer ->
                LocalVideoTrack.create(it, true, capturer, null, CAMERA_TRACK_NAME)
            }?.apply {
                localVideoTrackNames[name] = context.getString(R.string.camera_video_track)
                videoTrack = this
                isCameraOn = true
                publishCameraTrack(this)
            }
        }
    }

    private fun publishCameraTrack(localVideoTrack: LocalVideoTrack?) {
        if (isCameraOn) {
            localVideoTrack?.let {
                localParticipant?.publishTrack(it, LocalTrackPublicationOptions(TrackPriority.LOW))
            }
        }
    }

    private fun publishAudioTrack(localAudioTrack: LocalAudioTrack?) {
        if (isMicOn) {
            localAudioTrack?.let { localParticipant?.publishTrack(it) }
        }
    }

    private fun unPublishTrack(localVideoTrack: LocalVideoTrack?) = localVideoTrack?.let { localParticipant?.unpublishTrack(it) }

    private fun unPublishTrack(localAudioTrack: LocalAudioTrack?) = localAudioTrack?.let { localParticipant?.unpublishTrack(it) }

    private fun removeCameraTrack(isCameraOn: Boolean = this.isCameraOn) {
        localVideoTrack?.let { cameraVideoTrack ->
            unPublishTrack(cameraVideoTrack)
            localVideoTrackNames.remove(cameraVideoTrack.name)
            cameraVideoTrack.release()
            localVideoTrack = null
            this.isCameraOn = isCameraOn
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