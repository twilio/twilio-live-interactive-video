package com.twilio.livevideo.app.view

import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AlertDialog
import androidx.compose.ui.text.capitalize
import androidx.compose.ui.text.intl.Locale
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.navigation.fragment.findNavController
import com.twilio.livevideo.app.repository.model.ErrorResponse
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
                    is SignInViewEvent.OnContinueName -> goToSignInPasscodeScreen()
                    is SignInViewEvent.OnContinuePasscode -> goToHomeScreenScreen()
                    is SignInViewEvent.OnSignInError -> showErrorAlert(this.error)
                }
            }
        }
    }

    private fun showErrorAlert(error: ErrorResponse?) {
        context?.apply {
            val builder: AlertDialog.Builder = AlertDialog.Builder(this)

            val message = error?.explanation?.let {
                if (it.isNotEmpty())
                    it.capitalize(Locale.current)
                else
                    "Passcode incorrect"
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
            }

            val alertDialog = builder.create()
            alertDialog.show()
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