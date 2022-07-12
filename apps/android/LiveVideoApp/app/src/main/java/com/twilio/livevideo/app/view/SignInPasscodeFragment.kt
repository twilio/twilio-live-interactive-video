package com.twilio.livevideo.app.view

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.twilio.livevideo.app.databinding.FragmentSignInPasscodeBinding
import com.twilio.livevideo.app.util.PasscodeUtil
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class SignInPasscodeFragment : SignInBaseFragment() {

    lateinit var viewDataBinding: FragmentSignInPasscodeBinding

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        viewDataBinding = FragmentSignInPasscodeBinding.inflate(inflater, container, false)
        viewDataBinding.viewModel = viewModel
        viewDataBinding.lifecycleOwner = viewLifecycleOwner
        return viewDataBinding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        registerSignInPasscodeStringObserver()
    }

    private fun registerSignInPasscodeStringObserver() {
        viewModel.passcode.observe(viewLifecycleOwner) { viewModel.enablePasscodeContinue(it.length >= PasscodeUtil.FULL_PASSCODE_MIN_LENGTH) }
    }
}