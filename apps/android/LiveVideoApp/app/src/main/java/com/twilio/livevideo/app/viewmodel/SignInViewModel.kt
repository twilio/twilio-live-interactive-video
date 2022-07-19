package com.twilio.livevideo.app.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.twilio.livevideo.app.repository.LiveVideoRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class SignInViewModel @Inject constructor(private val liveVideoRepository: LiveVideoRepository) :
    ViewModel() {

    var userName: MutableLiveData<String> = MutableLiveData()
    var passcode: MutableLiveData<String> = MutableLiveData()

    private val _continuePasscodeEnabled: MutableLiveData<Boolean> = MutableLiveData(false)
    val continuePasscodeEnabled: LiveData<Boolean>
        get() = _continuePasscodeEnabled

    private val _continueNameEnabled: MutableLiveData<Boolean> = MutableLiveData(false)
    val continueNameEnabled: LiveData<Boolean>
        get() = _continueNameEnabled

    private val _isLoading: MutableLiveData<Boolean> = MutableLiveData(false)
    val isLoading: LiveData<Boolean>
        get() = _isLoading

    private val _screenEvent: MutableLiveData<SignInViewEvent?> = MutableLiveData()
    val screenEvent: LiveData<SignInViewEvent?>
        get() {
            val event = _screenEvent
            _screenEvent.value = null
            return event
        }

    fun onContinueName() {
        _screenEvent.value = SignInViewEvent.OnContinueName
    }

    fun enableNameContinue(value: Boolean?) {
        _continueNameEnabled.value = value ?: false
    }

    fun enablePasscodeContinue(value: Boolean?) {
        _continuePasscodeEnabled.value = value ?: false
    }

    fun onContinuePasscode() {
        passcode.value?.let { passcodeString ->
            userName.value?.let { userNameString ->
                viewModelScope.launch {
                    _isLoading.value = true
                    val response =
                        liveVideoRepository.verifyPasscode(passcodeString, userNameString)
                    if (response.isApiResponseSuccess && response.isVerified) {
                        _screenEvent.value = SignInViewEvent.OnContinuePasscode
                    } else {
                        _screenEvent.value = SignInViewEvent.OnSignInError(response.error)
                    }
                    _isLoading.value = false
                }
            }
        }
    }
}