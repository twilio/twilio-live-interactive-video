package com.twilio.livevideo.app.viewmodel

import androidx.arch.core.executor.testing.InstantTaskExecutorRule
import androidx.lifecycle.Observer
import com.twilio.livevideo.app.repository.LiveVideoRepository
import com.twilio.livevideo.app.repository.model.ErrorResponse
import com.twilio.livevideo.app.repository.model.VerifyPasscodeResponse
import com.twilio.livevideo.app.util.MainCoroutineScopeRule
import dagger.hilt.android.testing.HiltAndroidRule
import dagger.hilt.android.testing.HiltAndroidTest
import dagger.hilt.android.testing.HiltTestApplication
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.runBlockingTest
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mock
import org.mockito.Mockito.`when`
import org.mockito.MockitoAnnotations
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@HiltAndroidTest
@ExperimentalCoroutinesApi
@RunWith(RobolectricTestRunner::class)
@Config(application = HiltTestApplication::class, sdk = [28])
class SignInViewModelTest {

    @get:Rule
    val coroutineScope = MainCoroutineScopeRule()

    @get:Rule
    var hiltRule = HiltAndroidRule(this)

    @Rule
    @JvmField
    var mInstantTaskExecutorRule = InstantTaskExecutorRule()

    @Mock
    private lateinit var screenEventObserver: Observer<in SignInViewEvent?>

    private val liveVideoRepository = mock<LiveVideoRepository>()

    private lateinit var viewModel: SignInViewModel

    @Before
    fun setup() {
        MockitoAnnotations.openMocks(this)
        hiltRule.inject()

        viewModel = SignInViewModel(liveVideoRepository)
        viewModel.screenEvent.observeForever(screenEventObserver)
    }

    @Test
    fun `verify non-exist passcode`() {
        coroutineScope.runBlockingTest {
            // GIVEN
            val passcode = "123456789012345"
            val errorResponse = ErrorResponse("", "")
            `when`(liveVideoRepository.verifyPasscode(passcode)).thenReturn(
                VerifyPasscodeResponse(
                    false
                ).apply {
                    this.isApiResponseSuccess = false
                    this.code = 404
                    this.error = errorResponse
                })
            viewModel.passcode.value = passcode

            // WHEN
            verify(screenEventObserver).onChanged(null)
            viewModel.onContinuePasscode()

            // THEN
            verify(screenEventObserver).onChanged(SignInViewEvent.OnSignInError(errorResponse))
        }
    }

    @Test
    fun `verify valid passcode`() {
        coroutineScope.runBlockingTest {
            // GIVEN
            val passcode = "123456789012345"
            `when`(liveVideoRepository.verifyPasscode(passcode)).thenReturn(
                VerifyPasscodeResponse(
                    true
                ).apply {
                    this.isApiResponseSuccess = true
                    this.code = 202
                })
            viewModel.passcode.value = passcode

            // WHEN
            verify(screenEventObserver).onChanged(null)
            viewModel.onContinuePasscode()

            // THEN
            verify(screenEventObserver).onChanged(SignInViewEvent.OnContinuePasscode)
        }
    }
}