package com.twilio.livevideo.app.view

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.twilio.livevideo.app.databinding.FragmentSignInBinding
import dagger.hilt.android.AndroidEntryPoint
import timber.log.Timber

@AndroidEntryPoint
class SignInFragment : SignInBaseFragment() {

    lateinit var viewDataBinding: FragmentSignInBinding

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        //TODO: Add logic to check user credentials then skip signIn flow.
        viewDataBinding = FragmentSignInBinding.inflate(inflater, container, false)
        viewDataBinding.viewModel = viewModel
        viewDataBinding.lifecycleOwner = this
        return viewDataBinding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        Timber.d("SignInFragment onViewCreated")
        registerSignInNameStringObserver()
    }

    private fun registerSignInNameStringObserver() {
        viewModel.userName.observe(viewLifecycleOwner) { viewModel.enableNameContinue(it.isNotEmpty()) }
    }
}