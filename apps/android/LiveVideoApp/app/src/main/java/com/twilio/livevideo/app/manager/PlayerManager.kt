package com.twilio.livevideo.app.manager

import android.content.Context
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.twilio.live.player.Player
import com.twilio.live.player.PlayerException
import com.twilio.live.player.PlayerListener
import com.twilio.live.player.PlayerState
import com.twilio.live.player.PlayerView
import com.twilio.livevideo.app.annotations.OpenForTesting
import com.twilio.livevideo.app.custom.BaseLifeCycleComponent
import com.twilio.livevideo.app.repository.model.ErrorResponse
import timber.log.Timber
import javax.inject.Inject

@OpenForTesting
class PlayerManager @Inject constructor(private var context: Context?) :
    BaseLifeCycleComponent(),
    PlayerListener {

    private var player: Player? = null

    private val _onStateEvent: MutableLiveData<OnStateCallback?> =
        MutableLiveData<OnStateCallback?>(null)
    val onStateEvent: LiveData<OnStateCallback?>
        get() {
            val event = _onStateEvent
            _onStateEvent.value = null
            return event
        }

    fun connect(
        lifecycle: Lifecycle,
        playerView: PlayerView,
        accessToken: String
    ) {
        init(lifecycle)
        player = context?.let { Player.connect(it, accessToken, this) }
        player?.playerView = playerView
    }

    private fun play() {
        player?.play()
    }

    fun disconnect() {
        player?.pause()
        player = null
    }

    override fun onStateChanged(player: Player, playerState: PlayerState) {
        Timber.d("onStateChanged: ${playerState.name}")
        when (playerState) {
            PlayerState.IDLE -> {}
            PlayerState.READY -> play()
            PlayerState.BUFFERING -> {}
            PlayerState.PLAYING -> _onStateEvent.value = OnStateCallback.OnPlaying
            PlayerState.ENDED -> {
                _onStateEvent.value = OnStateCallback.OnEnded
                disconnect()
            }
        }
    }

    override fun onFailed(player: Player, playerException: PlayerException) {
        Timber.d("onFailed: ${playerException.message}")
        disconnect()
        _onStateEvent.value = OnStateCallback.OnError(
            ErrorResponse(
                playerException.message,
                playerException.explanation ?: ""
            )
        )
    }

    sealed class OnStateCallback {
        object OnPlaying : OnStateCallback()

        object OnEnded : OnStateCallback()

        data class OnError(val error: ErrorResponse) : OnStateCallback()
    }
}