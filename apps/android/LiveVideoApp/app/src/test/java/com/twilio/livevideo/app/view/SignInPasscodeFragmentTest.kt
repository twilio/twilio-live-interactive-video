package com.twilio.livevideo.app.view

import androidx.arch.core.executor.testing.InstantTaskExecutorRule
import com.twilio.livevideo.app.launchFragmentInHiltContainer
import com.twilio.livevideo.app.util.MainCoroutineScopeRule
import com.twilio.livevideo.app.util.PasscodeUtil
import dagger.hilt.android.testing.HiltAndroidRule
import dagger.hilt.android.testing.HiltAndroidTest
import dagger.hilt.android.testing.HiltTestApplication
import kotlinx.coroutines.ExperimentalCoroutinesApi
import org.junit.Assert
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@HiltAndroidTest
@ExperimentalCoroutinesApi
@RunWith(RobolectricTestRunner::class)
@Config(application = HiltTestApplication::class, sdk = [28])
class SignInPasscodeFragmentTest {

    @get:Rule
    val coroutineScope = MainCoroutineScopeRule()

    @get:Rule
    var hiltRule = HiltAndroidRule(this)

    @Rule
    @JvmField
    var mInstantTaskExecutorRule = InstantTaskExecutorRule()

    @Before
    fun setup() {
        launchFragmentInHiltContainer<SignInPasscodeFragment>()
    }

    @Test
    fun `it should enable the login button after typing 14 passcode digits`() {
        //GIVEN
        val passcode = "12345678901234"
        assertLoginPasscodeContinueButtonIsVisible()
        assertLoginPasscodeContinueButtonIsDisabled()

        //WHEN
        enterPasscode(passcode)

        //THEN
        isPasscodeEntered(passcode)
        assertLoginPasscodeContinueButtonIsEnabled()
    }

    @Test
    fun `it should keep disable the login button less than 14 passcode digits`() {
        //GIVEN
        val passcode = "1234567890"
        assertLoginPasscodeContinueButtonIsVisible()
        assertLoginPasscodeContinueButtonIsDisabled()

        //WHEN
        enterPasscode(passcode)

        //THEN
        isPasscodeEntered(passcode)
        assertLoginPasscodeContinueButtonIsDisabled()
    }

    @Test
    fun `process passcode when it is 14 digits`() {
        //GIVEN
        val passcode = "12345678901234"

        //WHEN
        val passcodeUrl = PasscodeUtil.extractPasscodeUrl(passcode)

        //THEN
        Assert.assertEquals(passcodeUrl, "7890-1234")
    }

    @Test
    fun `process passcode when it is 20 digits`() {
        //GIVEN
        val passcode = "12345678901234567890"

        //WHEN
        val passcodeUrl = PasscodeUtil.extractPasscodeUrl(passcode)

        //THEN
        Assert.assertEquals(passcodeUrl, "7890-1234567890")
    }

}
