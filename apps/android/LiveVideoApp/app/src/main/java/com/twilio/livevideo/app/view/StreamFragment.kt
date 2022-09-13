package com.twilio.livevideo.app.view

import android.content.Context
import android.media.AudioManager
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
import com.twilio.livevideo.app.manager.sync.SyncManager
import com.twilio.livevideo.app.manager.sync.SyncViewEvent
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
class StreamFragment : Fragment() {

    val commonViewModel: CommonStreamViewModel by activityViewModels()
    val viewModel: StreamViewModel by viewModels()
    internal val args: StreamFragmentArgs by navArgs()
    lateinit var viewDataBinding: FragmentStreamBinding

    @Inject
    lateinit var playerManager: PlayerManager

    @Inject
    lateinit var roomManager: RoomManager

    @Inject
    lateinit var syncManager: SyncManager

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
        setupSpeakerAudio()
        setupViewModel()
        registerOnViewStateObserver()
        registerOnExitEventButton()
    }

    private fun setupSpeakerAudio() {
        activity?.apply {
            (getSystemService(Context.AUDIO_SERVICE) as? AudioManager)?.also { audioService ->
                audioService.mode = AudioManager.MODE_IN_CALL
                audioService.isSpeakerphoneOn = true
            }
        }
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
                setupInitialStateBottomControls(false)
                registerOnSwitchCamEventButton()
                registerOnSwitchMicEventButton()
            }
            ViewRole.Speaker -> {
                setupInitialStateBottomControls(false)
                registerOnSwitchCamEventButton()
                registerOnSwitchMicEventButton()
                registerOnClickMenuEventButton()
            }
            ViewRole.Viewer -> {
                setupInitialStateBottomControls(true)
                registerOnRaiseHandEventButton()
            }
            else -> {}
        }
    }

    private fun registerOnRaiseHandEventButton() {
        viewDataBinding.raiseHandEvent.setOnCheckedChangeListener { _, b ->
            viewModel.raiseHand(b)
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

    private fun transitionViewerToSpeaker() {
        playerManager.disconnect()
        viewModel.transitionToSpeaker()
    }

    private fun setupInitialStateBottomControls(isViewer: Boolean) {
        if (isViewer) {
            viewDataBinding.raiseHandEvent.isEnabled = true
        } else {
            viewDataBinding.videoSwitchEvent.isEnabled = true
            viewDataBinding.videoSwitchEvent.isChecked = roomManager.localParticipantWrapper.isCameraOn
            viewDataBinding.micSwitchEvent.isEnabled = true
            viewDataBinding.micSwitchEvent.isChecked = roomManager.localParticipantWrapper.isMicOn
        }
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

    private fun disconnectStream(fromAlertDialog: Boolean = false) {
        when (viewModel.viewState.value?.role) {
            ViewRole.Host -> disconnectHost(fromAlertDialog)
            ViewRole.Speaker -> disconnectSpeaker()
            ViewRole.Viewer -> disconnectViewer()
            else -> {}
        }
    }

    private fun disconnectViewer() {
        syncManager.disconnect()
        playerManager.disconnect()
        navigateToHomeScreen()
    }

    private fun disconnectHost(fromAlertDialog: Boolean) {
        fun disconnectProcess() {
            syncManager.disconnect()
            gridManager.clean()
            roomManager.disconnect()
            viewModel.deleteStream()
        }
        if (fromAlertDialog) {
            disconnectProcess()
        } else {
            showErrorAlert(
                ErrorResponse(
                    getString(R.string.twilio_host_disconnect_stream_title),
                    getString(R.string.twilio_host_disconnect_stream_description)
                ), positiveCallback = {
                    disconnectProcess()
                }, positiveButtonText = "End event",
                negativeButtonText = "Never mind"
            )
        }
    }

    private fun disconnectSpeaker() {
        syncManager.disconnect()
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
            positiveCallback = { disconnectStream(true) }
        )
    }

    private fun onAction(event: StreamViewEvent) {
        Timber.d("onAction StreamViewEvent $event")
        when (event) {
            is StreamViewEvent.OnConnectViewer -> {
                connectSync(event.token, true)
                connectPlayer(event.token)
                viewModel.viewerConnectedToPlayer(commonViewModel.userIdentity)
            }
            is StreamViewEvent.OnCreateStream -> {
                connectRoom(event.token, true)
                connectSync(event.token, false)
                viewModel.onLoadingFinish(isLiveActive = true)
            }
            is StreamViewEvent.OnConnectSpeaker -> {
                connectSync(event.token, true)
                connectRoom(event.token)
                viewModel.onLoadingFinish(isLiveActive = true)
            }
            StreamViewEvent.OnDeleteStream -> navigateToHomeScreen()
            is StreamViewEvent.OnStreamError -> showErrorAlert(event.error, positiveCallback = { navigateToHomeScreen() })
            is StreamViewEvent.OnSpeakerDisconnected -> {}
            is StreamViewEvent.OnViewerRaiseHand -> {
                Timber.d("OnViewerRaiseHand event error ${event.error}")
            }
        }
    }

    private fun registerSyncObjects() {
        syncManager.documentLiveData.observe(viewLifecycleOwner) { event ->
            Timber.d("documentLiveData event: $event")
            when (event) {
                SyncViewEvent.OnDocumentSpeakerInvite -> {
                    showErrorAlert(
                        ErrorResponse(
                            "It's your time to shine!",
                            "The host has invited you to join as a Speaker. Your audio and video will be shared."
                        ),
                        { transitionViewerToSpeaker() }, "Join now",
                        {}, "Never mind"
                    )
                }
                else -> {}
            }
        }

        syncManager.raisedHandsMapLiveData.observe(viewLifecycleOwner) { event ->
            Timber.d("raisedHandsMapLiveData event: $event")
            when (event) {
                is SyncViewEvent.OnMapItemAdded -> {
                    //TODO: Implement/Update participants UI List
                    /*event.syncUser.identity?.also { identity ->
                        roomManager.sid?.apply {
                            Timber.d("raisedHandsMapLiveData room sid: $this")
                            viewModel.sendSpeakerInvite(identity, roomSid = this)
                        }
                    }*/
                }
                is SyncViewEvent.OnMapItemRemoved -> {}
                is SyncViewEvent.OnError -> {}
                else -> {}
            }
        }

        syncManager.viewersMapLiveData.observe(viewLifecycleOwner) { event ->
            Timber.d("viewerMapLiveData event: $event")
            when (event) {
                is SyncViewEvent.OnMapItemAdded -> {}
                is SyncViewEvent.OnMapItemRemoved -> {}
                is SyncViewEvent.OnError -> {}
                else -> {}
            }
        }

        syncManager.speakersMapLiveData.observe(viewLifecycleOwner) { event ->
            Timber.d("speakerMapLiveData event: $event")
            when (event) {
                is SyncViewEvent.OnMapItemAdded -> {}
                is SyncViewEvent.OnMapItemRemoved -> {}
                is SyncViewEvent.OnError -> {}
                else -> {}
            }
        }
    }

    private fun connectSync(token: String, hasUserDocument: Boolean) {
        Timber.e("connectSync Exception - syncManager.isConnected:${syncManager.isConnected}")
        if (syncManager.isConnected) return

        syncManager.connect(viewLifecycleOwner, token, commonViewModel.userIdentity, hasUserDocument) { error ->
            error?.apply {
                Timber.d("connectSync With Error ${error.message}")
                showErrorAlert(
                    ErrorResponse(
                        "Sync Completion Error - ${this.code}",
                        this.message
                    ), positiveCallback = { disconnectStream(true) })
            } ?: run {
                Timber.d("connectSync Success")
                registerSyncObjects()
            }
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
                        is RoomDisconnectionType.UnknownDisconnection -> {}
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
                    setupBottomControllers()
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