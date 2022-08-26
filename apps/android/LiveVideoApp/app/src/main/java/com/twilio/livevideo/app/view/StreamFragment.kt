package com.twilio.livevideo.app.view

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.widget.PopupMenu
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
import com.twilio.livevideo.app.manager.GridManager
import com.twilio.livevideo.app.manager.PlayerManager
import com.twilio.livevideo.app.manager.room.RoomDisconnectionType
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

    @Inject
    lateinit var gridManager: GridManager

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
        activity?.window?.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        setupViewModel()
        registerOnViewStateObserver()
        registerOnExitEventButton()
    }

    override fun onDestroy() {
        activity?.window?.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        super.onDestroy()
    }

    private fun setupViewModel() {
        val role = args.viewRole
        viewModel.initViewState(role)
        initializedRole(role)
    }

    fun initializedRole(viewRole: ViewRole) {
        when (viewRole) {
            ViewRole.Host -> viewModel.createStream(commonViewModel.eventName)
            ViewRole.Speaker -> viewModel.joinStreamAsSpeaker(commonViewModel.eventName)
            ViewRole.Viewer -> viewModel.joinStreamAsViewer(commonViewModel.eventName)
        }
    }

    private fun navigateToHomeScreen() {
        findNavController().navigate(StreamFragmentDirections.actionStreamFragmentToHomeFragment())
    }

    private fun setupBottomControllers() {
        Timber.d("setupBottomControllers")
        when (viewModel.viewState.value?.role) {
            ViewRole.Host -> {
                setupInitialStateBottomControls()
                registerOnSwitchCamEventButton()
                registerOnSwitchMicEventButton()
            }
            ViewRole.Speaker -> {
                setupInitialStateBottomControls()
                registerOnSwitchCamEventButton()
                registerOnSwitchMicEventButton()
                registerOnClickMenuEventButton()
            }
            ViewRole.Viewer -> {}
            else -> {}
        }
    }

    private fun registerOnClickMenuEventButton() {
        val popup = PopupMenu(viewDataBinding.speakerMenu.context, viewDataBinding.speakerMenu)
        popup.menuInflater.inflate(R.menu.speaker_menu, popup.menu)

        popup.setOnMenuItemClickListener {
            transitionSpeakerToViewer()
            true
        }

        viewDataBinding.speakerMenu.setOnClickListener {
            popup.show()
        }
    }

    private fun transitionSpeakerToViewer() {
        roomManager.disconnect()
        gridManager.clean()
        viewModel.transitionToViewer()
    }

    private fun setupInitialStateBottomControls() {
        viewDataBinding.videoSwitchEvent.isEnabled = true
        viewDataBinding.videoSwitchEvent.isChecked = roomManager.localParticipantWrapper.isCameraOn
        viewDataBinding.micSwitchEvent.isEnabled = true
        viewDataBinding.micSwitchEvent.isChecked = roomManager.localParticipantWrapper.isMicOn
    }

    private fun registerOnSwitchMicEventButton() {
        viewDataBinding.micSwitchEvent.setOnCheckedChangeListener { _, b ->
            roomManager.localParticipantWrapper.toggleLocalAudio(b)
        }
    }

    private fun registerOnSwitchCamEventButton() {
        viewDataBinding.videoSwitchEvent.setOnCheckedChangeListener { _, b ->
            roomManager.localParticipantWrapper.toggleLocalVideo(b)
        }
    }

    private fun registerOnExitEventButton() {
        viewDataBinding.exitEvent.setOnClickListener {
            disconnectStream()
        }
    }

    private fun disconnectStream() {
        when (viewModel.viewState.value?.role) {
            ViewRole.Host -> disconnectHost()
            ViewRole.Speaker -> disconnectSpeaker()
            ViewRole.Viewer -> disconnectViewer()
            else -> {}
        }
    }

    private fun disconnectViewer() {
        playerManager.disconnect()
        navigateToHomeScreen()
    }

    private fun disconnectHost() {
        showErrorAlert(
            ErrorResponse(
                getString(R.string.twilio_host_disconnect_stream_title),
                getString(R.string.twilio_host_disconnect_stream_description)
            ), positiveCallback = {
                gridManager.clean()
                roomManager.disconnect()
                viewModel.deleteStream()
            }, positiveButtonText = "End event",
            negativeButtonText = "Never mind"
        )
    }

    private fun disconnectSpeaker() {
        gridManager.clean()
        roomManager.disconnect()
        navigateToHomeScreen()
    }

    private fun registerOnViewStateObserver() {
        viewModel.screenEvent.observe(viewLifecycleOwner) {
            it?.apply {
                onAction(this)
            }
        }
    }

    private fun showDisconnectedRoomAlert() {
        showErrorAlert(
            ErrorResponse(
                getString(R.string.twilio_join_event_ended_title),
                getString(R.string.twilio_join_event_ended_description)
            ),
            positiveCallback = { navigateToHomeScreen() }
        )
    }

    private fun onAction(event: StreamViewEvent) {
        Timber.d("onAction StreamViewEvent $event")
        when (event) {
            is StreamViewEvent.OnConnectViewer -> connectPlayer(event.token)
            is StreamViewEvent.OnCreateStream -> {
                connectRoom(event.token, true)
                viewModel.onLoadingFinish(isLiveActive = true)
            }
            is StreamViewEvent.OnConnectSpeaker -> {
                connectRoom(event.token)
                viewModel.onLoadingFinish(isLiveActive = true)
            }
            StreamViewEvent.OnDeleteStream -> navigateToHomeScreen()
            is StreamViewEvent.OnStreamError -> showErrorAlert(event.error, positiveCallback = { navigateToHomeScreen() })
            is StreamViewEvent.OnSpeakerDisconnected -> {}
        }
    }

    private fun connectRoom(token: String, isHost: Boolean = false) {
        roomManager.onStateEvent.observe(viewLifecycleOwner) { event ->

            when (event) {
                is RoomViewEvent.OnConnected -> {
                    registerGridManagerStateEvent()
                    setupBottomControllers()
                    gridManager.addParticipant(event.participants)
                }
                is RoomViewEvent.OnDisconnected -> {
                    when (event.disconnectionType) {
                        RoomDisconnectionType.StreamEndedByHost -> showDisconnectedRoomAlert()
                        RoomDisconnectionType.SpeakerMovedToViewersByHost -> createSpeakerMovedToViewersByHostDialog()
                        null -> {}
                    }
                }
                is RoomViewEvent.OnRemoteParticipantConnected -> {
                    gridManager.addParticipant(event.participant)
                    viewModel.updateOffScreenParticipants(gridManager.getOffScreenCount())
                }
                is RoomViewEvent.OnRemoteParticipantDisconnected -> {
                    gridManager.removeParticipant(event.participantIdentity)
                    viewModel.updateOffScreenParticipants(gridManager.getOffScreenCount())
                }
                is RoomViewEvent.OnDominantSpeakerChanged -> {
                    gridManager.updateDominantSpeaker(event.participantIdentity)
                }
                is RoomViewEvent.OnError -> {
                    showErrorAlert(event.error, positiveCallback = { navigateToHomeScreen() })
                }
                null -> {}
            }

        }
        roomManager.connect(viewLifecycleOwner, commonViewModel.eventName, token, isHost)
    }

    private fun createSpeakerMovedToViewersByHostDialog() {
        transitionSpeakerToViewer()
        showErrorAlert(
            ErrorResponse(
                getString(R.string.twilio_transition_moved_to_viewers_title),
                getString(R.string.twilio_transition_moved_to_viewers_description)
            ), positiveCallback = {})
    }

    private fun registerGridManagerStateEvent() {
        gridManager.init(lifecycle, viewDataBinding.gridLayoutContainer)
        gridManager.onStateEvent.observe(viewLifecycleOwner) { event ->
            when (event) {
                is GridManager.GridManagerEvent.OnTransitionHostMoveSpeakerAsViewer -> {
                    viewModel.removeSpeaker(event.identity)
                }
                null -> {}
            }
        }
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
                    showDisconnectedRoomAlert()
                }
                is PlayerManager.OnStateCallback.OnError -> {
                    Timber.d("OnStateCallback onError")
                    viewModel.onLoadingFinish(isLiveActive = false)
                    showErrorAlert(it.error, positiveCallback = { navigateToHomeScreen() })
                }
                null -> {}
            }
        }
        playerManager.connect(lifecycle, viewDataBinding.playerView, token)
    }

    private fun showErrorAlert(
        error: ErrorResponse?,
        positiveCallback: (() -> Unit),
        positiveButtonText: String = "Ok",
        negativeCallback: (() -> Unit)? = null,
        negativeButtonText: String? = null
    ) {
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
            builder.setPositiveButton(positiveButtonText) { p0, p1 ->
                p0.cancel()
                positiveCallback.invoke()
            }
            negativeButtonText?.apply {
                builder.setNegativeButton(this) { p0, p1 ->
                    p0.cancel()
                    negativeCallback?.invoke()
                }
            }

            val alertDialog = builder.create()
            alertDialog.show()
        }
    }
}