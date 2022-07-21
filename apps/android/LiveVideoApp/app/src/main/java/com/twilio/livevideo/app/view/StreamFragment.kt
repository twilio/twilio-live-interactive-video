package com.twilio.livevideo.app.view

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.app.AlertDialog
import androidx.compose.ui.text.capitalize
import androidx.compose.ui.text.intl.Locale
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.twilio.livevideo.app.R
import com.twilio.livevideo.app.annotations.OpenForTesting
import com.twilio.livevideo.app.databinding.FragmentStreamBinding
import com.twilio.livevideo.app.manager.PlayerManager
import com.twilio.livevideo.app.manager.room.RoomManager
import com.twilio.livevideo.app.manager.room.RoomViewEvent
import com.twilio.livevideo.app.repository.model.ErrorResponse
import com.twilio.livevideo.app.viewmodel.CommonStreamViewModel
import com.twilio.livevideo.app.viewmodel.StreamViewEvent
import com.twilio.livevideo.app.viewmodel.StreamViewModel
import com.twilio.livevideo.app.viewstate.ViewRole
import dagger.hilt.android.AndroidEntryPoint
import timber.log.Timber
import javax.inject.Inject

@AndroidEntryPoint
@OpenForTesting
class StreamFragment internal constructor() : Fragment() {

    val commonViewModel: CommonStreamViewModel by activityViewModels()
    val viewModel: StreamViewModel by viewModels()
    internal val args: StreamFragmentArgs by navArgs()
    lateinit var viewDataBinding: FragmentStreamBinding

    @Inject
    lateinit var playerManager: PlayerManager

    @Inject
    lateinit var roomManager: RoomManager

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        viewDataBinding = FragmentStreamBinding.inflate(inflater, container, false)
        viewDataBinding.viewModel = viewModel
        viewDataBinding.lifecycleOwner = viewLifecycleOwner
        return viewDataBinding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupViewModel()
        registerOnViewStateObserver()
        registerOnExitEventButton()
    }

    private fun registerOnExitEventButton() {
        viewDataBinding.exitEvent.setOnClickListener {
            disconnectStream()
        }
    }

    private fun disconnectStream() {
        when (args.viewRole) {
            ViewRole.Host -> disconnectHost()
            ViewRole.Speaker -> disconnectSpeaker()
            ViewRole.Viewer -> disconnectViewer()
        }
    }

    private fun disconnectViewer() {
        playerManager.disconnect()
        navigateToHomeScreen()
    }

    private fun disconnectHost() {
        //TODO: Disconnect all the SDKs
        roomManager.disconnect()
        viewModel.deleteStream()
    }

    private fun disconnectSpeaker() {
        //TODO: Disconnect all the SDKs
        roomManager.disconnect()
        navigateToHomeScreen()
    }

    protected fun registerOnViewStateObserver() {
        viewModel.screenEvent.observe(viewLifecycleOwner) {
            it?.apply {
                onAction(this)
            }
        }
    }

    fun onAction(event: StreamViewEvent) {
        Timber.d("onAction StreamViewEvent $event")
        when (event) {
            is StreamViewEvent.OnConnectViewer -> connectPlayer(event.token)
            is StreamViewEvent.OnCreateStream -> {
                connectRoom(event.token)
                viewModel.onLoadingFinish(isLiveActive = true)
            }
            StreamViewEvent.OnDeleteStream -> navigateToHomeScreen()
            is StreamViewEvent.OnStreamError -> showErrorAlert(event.error)
        }
    }

    private fun connectRoom(token: String) {
        roomManager.onStateEvent.observe(viewLifecycleOwner) { event ->
            when (event) {
                is RoomViewEvent.OnConnected -> {
                    //TODO: change UI to render grid mode(Multiple VideoTracks)
                    event.participants.first().participantWrapper.videoTrack?.addSink(viewDataBinding.localVideo)
                }
                is RoomViewEvent.OnDisconnect -> {
                    //TODO: update only UI if it is required
                }
                is RoomViewEvent.OnDominantSpeakerUpdate -> {}
                is RoomViewEvent.OnRemoteParticipantConnected -> {}
                is RoomViewEvent.OnRemoteParticipantDisconnected -> {}
                is RoomViewEvent.OnRemoteParticipantUpdate -> {}
                is RoomViewEvent.OnNetworkQualityLevelChange -> {}
                null -> {}
            }
        }
        roomManager.connect(viewLifecycleOwner, commonViewModel.eventName, token, true)
    }

    private fun connectPlayer(token: String) {
        Timber.d("connectPlayer")
        playerManager.onStateEvent.observe(viewLifecycleOwner) {
            when (it) {
                PlayerManager.OnStateCallback.OnPlaying -> {
                    Timber.d("OnStateCallback onPlaying")
                    viewModel.onLoadingFinish(isLiveActive = true)
                }
                PlayerManager.OnStateCallback.OnEnded -> {
                    Timber.d("OnStateCallback onEnded")
                    viewModel.onLoadingFinish(isLiveActive = false)
                    showErrorAlert(
                        ErrorResponse(
                            getString(R.string.twilio_join_event_ended_title),
                            getString(R.string.twilio_join_event_ended_description)
                        )
                    )
                }
                is PlayerManager.OnStateCallback.OnError -> {
                    Timber.d("OnStateCallback onError")
                    viewModel.onLoadingFinish(isLiveActive = false)
                    showErrorAlert(it.error)
                }
                null -> {}
            }
        }
        playerManager.connect(lifecycle, viewDataBinding.playerView, token)
    }

    private fun navigateToHomeScreen() {
        findNavController().navigate(StreamFragmentDirections.actionStreamFragmentToHomeFragment())
    }

    private fun setupViewModel() {
        val role = args.viewRole
        viewModel.initViewState(role)
        initializedRole(role)
    }

    fun initializedRole(viewRole: ViewRole) {
        when (viewRole) {
            ViewRole.Host -> viewModel.createStream(commonViewModel.eventName)
            ViewRole.Speaker -> {}
            ViewRole.Viewer -> viewModel.joinStreamAsViewer(commonViewModel.eventName)
        }
    }

    private fun showErrorAlert(error: ErrorResponse?) {
        context?.apply {
            val builder: AlertDialog.Builder = AlertDialog.Builder(this)

            val message = error?.explanation?.let {
                if (it.isNotEmpty())
                    it.capitalize(Locale.current)
                else
                    "Event ended"
            }
            builder.setMessage(message)

            val title = error?.message?.let {
                if (it.isNotEmpty())
                    it.capitalize(Locale.current)
                else
                    "Error"
            }
            builder.setTitle(title)
            builder.setCancelable(false)
            builder.setPositiveButton("Ok") { p0, p1 ->
                p0.cancel()
                navigateToHomeScreen()
            }

            val alertDialog = builder.create()
            alertDialog.show()
        }
    }
}