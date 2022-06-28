package com.twilio.livevideo.app.view

import androidx.test.espresso.Espresso
import androidx.test.espresso.action.ViewActions.click
import androidx.test.espresso.action.ViewActions.replaceText
import androidx.test.espresso.action.ViewActions.scrollTo
import androidx.test.espresso.assertion.ViewAssertions.matches
import androidx.test.espresso.matcher.ViewMatchers
import androidx.test.espresso.matcher.ViewMatchers.isEnabled
import androidx.test.espresso.matcher.ViewMatchers.withId
import androidx.test.espresso.matcher.ViewMatchers.withText
import com.twilio.livevideo.app.R
import org.hamcrest.CoreMatchers

fun enterPasscode(passcode: String) {
    Espresso.onView(withId(R.id.passcode_input))
        .perform(replaceText(passcode))
}

fun isPasscodeEntered(passcode: String) {
    Espresso.onView(withId(R.id.passcode_input)).check(matches(withText(passcode)))
}

fun assertLoginPasscodeContinueButtonIsVisible() {
    Espresso.onView(withId(R.id.button_passcode))
        .check(matches(ViewMatchers.isDisplayed()))
}

fun assertLoginPasscodeContinueButtonIsDisabled() {
    Espresso.onView(withId(R.id.button_passcode))
        .check(matches(CoreMatchers.not(isEnabled())))
}

fun assertLoginPasscodeContinueButtonIsEnabled() {
    Espresso.onView(withId(R.id.button_passcode))
        .check(matches(isEnabled()))
}