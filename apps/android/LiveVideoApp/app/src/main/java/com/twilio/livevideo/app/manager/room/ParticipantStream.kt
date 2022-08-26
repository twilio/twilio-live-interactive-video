package com.twilio.livevideo.app.manager.room

import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.twilio.livevideo.app.custom.BaseLifeCycleComponent
import com.twilio.video.Participant
import com.twilio.video.VideoTrack
import timber.log.Timber
import java.util.Calendar
import java.util.Date


abstract class ParticipantStream : BaseLifeCycleComponent() {

    private val mSid: MutableLiveData<String?> = MutableLiveData(null)
    val sidLiveData: LiveData<String?>
        get() = mSid
    val sid: String?
        get() = mSid.value

    var dominantSpeakerStartTime: Date = Calendar.getInstance().time

    private val mIdentity: MutableLiveData<String?> = MutableLiveData(null)
    val identityLiveData: LiveData<String?>
        get() = mIdentity
    val identity: String?
        get() = mIdentity.value

    private val mVideoTrack: MutableLiveData<VideoTrack?> = MutableLiveData(null)
    val videoTrackLivedata: LiveData<VideoTrack?>
        get() = mVideoTrack
    var videoTrack: VideoTrack?
        get() = mVideoTrack.value
        set(value) {
            mVideoTrack.value = value
        }

    private val mIsDominantSpeaker: MutableLiveData<Boolean> = MutableLiveData(false)
    val isDominantSpeakerLiveData: LiveData<Boolean>
        get() = mIsDominantSpeaker
    var isDominantSpeaker: Boolean
        get() = mIsDominantSpeaker.value ?: false
        set(value) {
            dominantSpeakerStartTime = Calendar.getInstance().time
            mIsDominantSpeaker.value = value
        }

    private val mIsMicOn: MutableLiveData<Boolean> = MutableLiveData(false)
    val isMicOnLiveData: LiveData<Boolean>
        get() = mIsMicOn
    var isMicOn: Boolean
        get() = mIsMicOn.value ?: false
        set(value) {
            mIsMicOn.value = value
        }

    private val mIsCameraOn: MutableLiveData<Boolean> = MutableLiveData(false)
    val isCameraOnLiveData: LiveData<Boolean>
        get() = mIsCameraOn
    var isCameraOn: Boolean
        get() = mIsCameraOn.value ?: false
        set(value) {
            mIsCameraOn.value = value
        }

    private val mIsLocalHost: MutableLiveData<Boolean> = MutableLiveData(false)
    val isLocalHostLiveData: LiveData<Boolean>
        get() = mIsLocalHost
    var isLocalHost: Boolean
        get() = mIsLocalHost.value ?: false
        set(value) {
            mIsLocalHost.value = value
        }

    private val mIsHost: MutableLiveData<Boolean> = MutableLiveData(false)
    val isHostLiveData: LiveData<Boolean>
        get() = mIsHost
    var isHost: Boolean
        get() = mIsHost.value ?: false
        set(value) {
            mIsHost.value = value
        }

    private val mParticipant: MutableLiveData<Participant?> = MutableLiveData(null)
    val participantLiveData: LiveData<Participant?>
        get() = mParticipant
    var participant: Participant?
        get() = mParticipant.value
        set(value) {
            mParticipant.value = value
            mSid.value = value?.sid
            mIdentity.value = value?.identity
        }

    override fun onCreate(owner: LifecycleOwner) {
        Timber.i("onCreateCallback $identity")
    }

    override fun onStart(owner: LifecycleOwner) {
        Timber.i("onStartCallback $identity")
    }

    override fun onResume(owner: LifecycleOwner) {
        Timber.i("onResumeCallback $identity")
    }

    override fun onPause(owner: LifecycleOwner) {
        Timber.i("onPauseCallback $identity")
    }

    override fun onStop(owner: LifecycleOwner) {
        Timber.i("onStopCallback $identity")
    }

    override fun onDestroy(owner: LifecycleOwner) {
        Timber.i("onDestroyCallback $identity object: $this")
    }
}