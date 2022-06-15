package com.twilio.livevideo.app.view

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.twilio.livevideo.app.R
import com.twilio.livevideo.app.databinding.FragmentHomeEventNameBinding
import com.twilio.livevideo.app.viewmodel.HomeEventNameViewModel
import dagger.hilt.android.AndroidEntryPoint
import timber.log.Timber

@AndroidEntryPoint
class HomeEventNameFragment : Fragment() {

    private val viewModel: HomeEventNameViewModel by viewModels()
    private val args: HomeEventNameFragmentArgs by navArgs()
    lateinit var viewDataBinding: FragmentHomeEventNameBinding

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        viewDataBinding = FragmentHomeEventNameBinding.inflate(inflater, container, false)
        viewDataBinding.viewModel = viewModel
        viewDataBinding.lifecycleOwner = this
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
            Timber.d("register OnContinueNewEventClickListener")
            //TODO:Validate if the Room Name is valid then proceed to the Room Screen
        }
    }

    private fun registerOnContinueJoinEventClickListener() {
        viewDataBinding.joinEventLayout.button1.setOnClickListener {
            Timber.d("register OnContinueJoinEventClickListener")
            val navController = findNavController()
            navController.navigate(HomeEventNameFragmentDirections.actionHomeEventNameFragmentToHomeJoinTypeFragment())
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
}