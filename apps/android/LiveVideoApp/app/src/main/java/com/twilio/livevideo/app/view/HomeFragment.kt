package com.twilio.livevideo.app.view

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import com.twilio.livevideo.app.databinding.FragmentHomeBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class HomeFragment : Fragment() {

    lateinit var viewDataBinding: FragmentHomeBinding

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        viewDataBinding = FragmentHomeBinding.inflate(inflater, container, false)
        viewDataBinding.lifecycleOwner = this
        return viewDataBinding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        registerOnClickListeners()
    }

    private fun registerOnClickListeners() {
        val navController = findNavController()
        viewDataBinding.createEventButton.eventButton.setOnClickListener {
            navController.navigate(
                HomeFragmentDirections.actionHomeFragmentToHomeEvenNameFragment(
                    isNewEvent = true
                )
            )
        }

        viewDataBinding.joinEventButton.eventButton.setOnClickListener {
            navController.navigate(
                HomeFragmentDirections.actionHomeFragmentToHomeEvenNameFragment(
                    isNewEvent = false
                )
            )
        }
    }
}