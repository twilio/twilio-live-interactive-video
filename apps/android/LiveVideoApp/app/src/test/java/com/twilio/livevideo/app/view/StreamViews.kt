package com.twilio.livevideo.app.view

import androidx.test.espresso.Espresso
import androidx.test.espresso.assertion.ViewAssertions
import androidx.test.espresso.matcher.ViewMatchers
import com.twilio.livevideo.app.R
import org.hamcrest.CoreMatchers

fun assertLoadingSpinnerIsDisplayed() {
    Espresso.onView(ViewMatchers.withId(R.id.loader_spinner))
        .check(ViewAssertions.matches(ViewMatchers.isDisplayed()))
}

fun assertLoadingSpinnerIsNotDisplayed() {
    Espresso.onView(ViewMatchers.withId(R.id.loader_spinner))
        .check(ViewAssertions.matches(CoreMatchers.not(ViewMatchers.isDisplayed())))
}