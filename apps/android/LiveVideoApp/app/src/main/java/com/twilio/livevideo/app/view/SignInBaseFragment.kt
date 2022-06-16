package com.twilio.livevideo.app.view

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.navigation.fragment.findNavController
import com.twilio.livevideo.app.viewmodel.SignInViewEvent
import com.twilio.livevideo.app.viewmodel.SignInViewModel
import dagger.hilt.android.AndroidEntryPoint
import timber.log.Timber

@AndroidEntryPoint
open class SignInBaseFragment : Fragment() {

    protected val viewModel: SignInViewModel by activityViewModels()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        registerViewEventObserver()
    }

    private fun registerViewEventObserver() {
        viewModel.screenEvent.observe(viewLifecycleOwner) { event ->
            Timber.d("SignInFragment view event $event")
            event?.apply {
                when (this) {
                    SignInViewEvent.OnContinueName -> goToSignInPasscodeScreen()
                    SignInViewEvent.OnContinuePasscode -> goToHomeScreenScreen()
                }
            }
        }
    }

    private fun goToSignInPasscodeScreen() {
        val navController = findNavController()
        navController.navigate(SignInFragmentDirections.actionSignInFragmentToSignInPasscodeFragment())
    }

    private fun goToHomeScreenScreen() {
        val navController = findNavController()
        navController.navigate(SignInPasscodeFragmentDirections.actionSignInPasscodeFragmentToHomeFragment())
    }
}