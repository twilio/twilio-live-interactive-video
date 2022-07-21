package com.twilio.livevideo.app.custom

import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import timber.log.Timber

abstract class BaseLifeCycleComponent : DefaultLifecycleObserver {

    open fun init(lifecycle: Lifecycle) {
        lifecycle.addObserver(this)
    }

    override fun onCreate(owner: LifecycleOwner) {
        Timber.i("onCreateCallback")
    }

    override fun onStart(owner: LifecycleOwner) {
        Timber.i("onStartCallback")
    }

    override fun onResume(owner: LifecycleOwner) {
        Timber.i("onResumeCallback")
    }

    override fun onPause(owner: LifecycleOwner) {
        Timber.i("onPauseCallback")
    }

    override fun onStop(owner: LifecycleOwner) {
        Timber.i("onStopCallback")
    }

    override fun onDestroy(owner: LifecycleOwner) {
        Timber.i("onDestroyCallback")
    }
}