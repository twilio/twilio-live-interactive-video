package com.twilio.livevideo.app.view

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import com.twilio.livevideo.app.databinding.FragmentHomeJoinTypeBinding
import com.twilio.livevideo.app.viewstate.ViewRole
import dagger.hilt.android.AndroidEntryPoint
import timber.log.Timber

@AndroidEntryPoint
class HomeJoinEventTypeFragment : Fragment() {

    lateinit var viewDataBinding: FragmentHomeJoinTypeBinding

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        viewDataBinding = FragmentHomeJoinTypeBinding.inflate(inflater, container, false)
        viewDataBinding.lifecycleOwner = viewLifecycleOwner
        return viewDataBinding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        registerOnSpeakerClickListener()
        registerOnViewerClickListener()
    }

    private fun registerOnViewerClickListener() {
        viewDataBinding.joinAsViewerButton.eventButton.setOnClickListener {
            Timber.d("register OnViewerClickListener")
            findNavController().navigate(
                HomeJoinEventTypeFragmentDirections.actionHomeJoinTypeFragmentToStreamFragment(
                    ViewRole.Viewer
                )
            )
        }
    }

    private fun registerOnSpeakerClickListener() {
        viewDataBinding.joinAsSpeakerButton.eventButton.setOnClickListener {
            Timber.d("register OnSpeakerClickListener")
        }
    }
}