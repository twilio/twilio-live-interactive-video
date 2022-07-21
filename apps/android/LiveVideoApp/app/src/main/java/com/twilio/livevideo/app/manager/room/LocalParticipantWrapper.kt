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
import com.twilio.video.NetworkQualityLevel
import com.twilio.video.TrackPriority
import com.twilio.video.TwilioException
import com.twilio.video.ktx.createLocalAudioTrack
import timber.log.Timber
import javax.inject.Inject

class LocalParticipantWrapper @Inject constructor(private val context: Context?) :
    ParticipantWrapper<LocalVideoTrack, LocalParticipant>(), LocalParticipant.Listener {

    internal var localAudioTrack: LocalAudioTrack? = null

    private var cameraCapturer: CameraCapturerCompat? = null

    override var participant: LocalParticipant?
        get() = super.participant
        set(value) {
            value?.setListener(this)
            super.participant = value
        }

    private val localVideoTrackNames: MutableMap<String, String> = HashMap()

    override fun onResume(owner: LifecycleOwner) {
        super.onResume(owner)
        if (!isAudioMuted) setupLocalAudioTrack()
        if (!isVideoMuted) setupLocalVideoTrack()
    }

    override fun onPause(owner: LifecycleOwner) {
        super.onPause(owner)
        removeCameraTrack()
    }

    fun toggleLocalAudio() {
        if (!isAudioMuted) {
            isAudioMuted = true
            removeAudioTrack()
        } else {
            isAudioMuted = false
            setupLocalAudioTrack()
        }
    }

    fun toggleLocalVideo() {
        if (!isVideoMuted) {
            isVideoMuted = true
            removeCameraTrack()
        } else {
            isVideoMuted = false
            setupLocalVideoTrack()
        }
    }

    private fun setupLocalAudioTrack() {
        if (localAudioTrack == null && !isAudioMuted && context != null) {
            localAudioTrack = createLocalAudioTrack(context, true, MICROPHONE_TRACK_NAME)
            localAudioTrack?.let { publishAudioTrack(it) }
                ?: Timber.e(RuntimeException(), "Failed to create local audio track")
        }
    }

    private fun setupLocalVideoTrack() {
        context?.let {
            cameraCapturer = CameraCapturerCompat.newInstance(it)

            videoTrack = cameraCapturer?.let { capturer ->
                LocalVideoTrack.create(it, true, capturer, null, CAMERA_TRACK_NAME)
            }?.apply {
                localVideoTrackNames[name] = context.getString(R.string.camera_video_track)
                publishCameraTrack(this)
            }
        }
    }

    private fun publishCameraTrack(localVideoTrack: LocalVideoTrack?) {
        if (!isVideoMuted) {
            localVideoTrack?.let {
                participant?.publishTrack(
                    it,
                    LocalTrackPublicationOptions(TrackPriority.LOW)
                )
            }
        }
    }

    private fun publishAudioTrack(localAudioTrack: LocalAudioTrack?) {
        if (!isAudioMuted) {
            localAudioTrack?.let { participant?.publishTrack(it) }
        }
    }

    private fun unPublishTrack(localVideoTrack: LocalVideoTrack?) =
        localVideoTrack?.let { participant?.unpublishTrack(it) }

    private fun unPublishTrack(localAudioTrack: LocalAudioTrack?) =
        localAudioTrack?.let { participant?.unpublishTrack(it) }

    private fun removeCameraTrack() {
        videoTrack?.let { cameraVideoTrack ->
            unPublishTrack(cameraVideoTrack)
            localVideoTrackNames.remove(cameraVideoTrack.name)
            cameraVideoTrack.release()
            this.videoTrack = null
        }
    }

    private fun removeAudioTrack() {
        localAudioTrack?.let { localAudioTrack ->
            unPublishTrack(localAudioTrack)
            localAudioTrack.release()
            this.localAudioTrack = null
        }
    }

    override fun onNetworkQualityLevelChanged(localParticipant: LocalParticipant, networkQualityLevel: NetworkQualityLevel) {
        this.networkQualityLevel = networkQualityLevel
    }

    override fun onAudioTrackPublished(
        localParticipant: LocalParticipant,
        localAudioTrackPublication: LocalAudioTrackPublication
    ) {
        //TODO("Not yet implemented")
    }

    override fun onAudioTrackPublicationFailed(
        localParticipant: LocalParticipant,
        localAudioTrack: LocalAudioTrack,
        twilioException: TwilioException
    ) {
        //TODO("Not yet implemented")
    }

    override fun onVideoTrackPublished(
        localParticipant: LocalParticipant,
        localVideoTrackPublication: LocalVideoTrackPublication
    ) {
        //TODO("Not yet implemented")
    }

    override fun onVideoTrackPublicationFailed(
        localParticipant: LocalParticipant,
        localVideoTrack: LocalVideoTrack,
        twilioException: TwilioException
    ) {
        //TODO("Not yet implemented")
    }

    override fun onDataTrackPublished(
        localParticipant: LocalParticipant,
        localDataTrackPublication: LocalDataTrackPublication
    ) {
        //TODO("Not yet implemented")
    }

    override fun onDataTrackPublicationFailed(
        localParticipant: LocalParticipant,
        localDataTrack: LocalDataTrack,
        twilioException: TwilioException
    ) {
        //TODO("Not yet implemented")
    }

    companion object {
        private const val CAMERA_TRACK_NAME = "camera"
        private const val MICROPHONE_TRACK_NAME = "microphone"
    }
}