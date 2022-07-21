package com.twilio.livevideo.app.view

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.twilio.livevideo.app.R
import com.twilio.livevideo.app.databinding.FragmentHomeEventNameBinding
import com.twilio.livevideo.app.manager.permission.PermissionManager
import com.twilio.livevideo.app.manager.permission.PermissionType
import com.twilio.livevideo.app.viewmodel.CommonStreamViewModel
import com.twilio.livevideo.app.viewmodel.HomeEventNameViewModel
import com.twilio.livevideo.app.viewstate.ViewRole
import dagger.hilt.android.AndroidEntryPoint
import timber.log.Timber
import javax.inject.Inject

@AndroidEntryPoint
class HomeEventNameFragment : Fragment() {

    private val commonViewModel: CommonStreamViewModel by activityViewModels()
    private val viewModel: HomeEventNameViewModel by viewModels()
    private val args: HomeEventNameFragmentArgs by navArgs()
    lateinit var viewDataBinding: FragmentHomeEventNameBinding

    @Inject
    lateinit var permissionManager: PermissionManager

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        viewDataBinding = FragmentHomeEventNameBinding.inflate(inflater, container, false)
        viewDataBinding.viewModel = viewModel
        viewDataBinding.lifecycleOwner = viewLifecycleOwner
        return viewDataBinding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupViewModel()
        setupToolbar()
        registerEventNameObserver()
        registerOnContinueClickListener()
    }

    private fun registerOnContinueClickListener() {
        viewModel.isNewEvent.value?.apply {
            if (this) {
                registerOnContinueNewEventClickListener()
            } else {
                registerOnContinueJoinEventClickListener()
            }
        }
    }

    private fun registerOnContinueNewEventClickListener() {
        viewDataBinding.newEventLayout.button1.setOnClickListener {
            Timber.d("OnContinueNewEventClickListener")
            commonViewModel.eventName = viewModel.newEventName.value ?: ""
            checkPermissions()
        }
    }

    private fun registerOnContinueJoinEventClickListener() {
        viewDataBinding.joinEventLayout.button1.setOnClickListener {
            Timber.d("OnContinueJoinEventClickListener")
            commonViewModel.eventName = viewModel.joinEventName.value ?: ""
            findNavController().navigate(HomeEventNameFragmentDirections.actionHomeEventNameFragmentToHomeJoinTypeFragment())
        }
    }

    private fun registerEventNameObserver() {
        viewModel.isNewEvent.value?.apply {
            if (this) {
                registerNewEventNameObserver()
            } else {
                registerJoinEventNameObserver()
            }
        }
    }

    private fun registerJoinEventNameObserver() {
        viewModel.joinEventName.observe(viewLifecycleOwner) { viewModel.enableJoinEventContinue(it.isNotEmpty()) }
    }

    private fun registerNewEventNameObserver() {
        viewModel.newEventName.observe(viewLifecycleOwner) { viewModel.enableNewEventContinue(it.isNotEmpty()) }
    }

    private fun setupViewModel() {
        viewModel.setNewEvent(args.isNewEvent)
    }

    private fun setupToolbar() {
        viewModel.isNewEvent.value?.apply {
            (requireActivity() as MainActivity).toolbar.title = if (this)
                getString(R.string.home_create_new_event_button)
            else
                getString(R.string.home_join_event_button)
        }
    }

    private fun navigateToStreamingScreen() {
        findNavController().navigate(HomeEventNameFragmentDirections.actionHomeEventNameFragmentToStreamFragment(ViewRole.Host))
    }

    private fun checkPermissions() {
        context?.apply {
            permissionManager.request(PermissionType.CameraAudio)
                .rationale("Camera and Audio Record permissions are needed")
                .checkPermission { granted, resultCode, data ->
                    if (granted) {
                        navigateToStreamingScreen()
                    } else {
                        Toast.makeText(
                            context,
                            "Camera and Audio Record permissions not granted",
                            Toast.LENGTH_SHORT
                        ).show()
                    }
                }
        }
    }
}