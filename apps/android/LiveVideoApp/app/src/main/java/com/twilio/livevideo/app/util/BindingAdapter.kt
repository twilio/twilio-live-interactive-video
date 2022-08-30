package com.twilio.livevideo.app.util

import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.databinding.BindingAdapter
import com.twilio.livevideo.app.R
import com.twilio.video.VideoTextureView
import com.twilio.video.VideoTrack
import timber.log.Timber

@BindingAdapter("videoTrack")
fun VideoTextureView.updateVideoTrack(videoTrack: VideoTrack?) {
    Timber.d("gridView item updateVideoTrack - sinks: ${videoTrack?.sinks?.size}")
    if (videoTrack == null) {
        visibility = View.GONE
    } else {
        visibility = View.VISIBLE
        videoTrack.addSink(this)
    }
}

@BindingAdapter("setDominantSpeaker")
fun ViewGroup.selectDominantSpeaker(isDominantSpeaker: Boolean) {
    if (isDominantSpeaker) {
        background = ContextCompat.getDrawable(context, R.drawable.dominant_speaker_border)
    } else {
        setBackgroundColor(ContextCompat.getColor(context, R.color.dominant_speaker_no_selected))
    }
}

@BindingAdapter("participantsCount")
fun TextView.participantsCount(offScreenParticipantsCount: Int) {
    visibility = if (offScreenParticipantsCount > 0) {
        text = context.getString(R.string.off_screen_count, offScreenParticipantsCount)
        View.VISIBLE
    } else {
        View.GONE
    }
}