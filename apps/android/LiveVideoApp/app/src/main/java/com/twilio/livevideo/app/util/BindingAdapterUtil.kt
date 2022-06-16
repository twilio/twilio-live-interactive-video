package com.twilio.livevideo.app.util

import android.view.View
import androidx.databinding.BindingAdapter


@BindingAdapter("visibleOrGone")
fun View.visibleOrGone(isVisible: Boolean) {
    visibility = if (isVisible)
        View.VISIBLE
    else
        View.GONE
}

@BindingAdapter("visibleOrInvisible")
fun View.visibleOrInvisible(isVisible: Boolean) {
    visibility = if (isVisible)
        View.VISIBLE
    else
        View.INVISIBLE
}