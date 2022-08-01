package com.twilio.livevideo.app.util

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TableLayout
import android.widget.TableRow
import androidx.core.content.ContextCompat
import androidx.databinding.BindingAdapter
import androidx.lifecycle.ViewTreeLifecycleOwner
import com.twilio.livevideo.app.R
import com.twilio.livevideo.app.databinding.ParticipantViewItemBinding
import com.twilio.livevideo.app.manager.room.ParticipantStream
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
        setBackgroundColor(ContextCompat.getColor(context, R.color.dominant_speaker_selected))
    } else {
        setBackgroundColor(ContextCompat.getColor(context, R.color.dominant_speaker_no_selected))
    }
}

@BindingAdapter("updateParticipants")
fun TableLayout.updateParticipants(participants: List<ParticipantStream>?) {
    Timber.d("gridView updateParticipants - Participants Count ${participants?.size}")
    ViewTreeLifecycleOwner.get(this)?.let { lifecycleOwner ->
        val inflater = LayoutInflater.from(context)
        val rowList: MutableList<TableRow> = mutableListOf()
        this.isStretchAllColumns = true
        this.isShrinkAllColumns = true
        this.removeAllViews()
        participants?.forEachIndexed { index, item ->

            var participantViewBinding: ParticipantViewItemBinding? = null

            participantViewBinding = ParticipantViewItemBinding.inflate(inflater, this, false)
            participantViewBinding.item = item
            participantViewBinding.lifecycleOwner = lifecycleOwner

            rowList.add(participantViewBinding.tableRowItem)
            this.addView(
                participantViewBinding.root,
                TableLayout.LayoutParams(TableLayout.LayoutParams.MATCH_PARENT, TableLayout.LayoutParams.MATCH_PARENT, 1F / participants.size)
            )

            /**
             * TODO: Work In Progress, logic to support grid mode. For now, it's showing all the participants in vertical only in vertical
            val count = (index + 1)
            if (participants.size <= 3) {

            participantViewBinding = ParticipantViewItemBinding.inflate(inflater, this, false)
            participantViewBinding.item = item.wrapper
            participantViewBinding.lifecycleOwner = lifecycleOwner

            rowList.add(participantViewBinding.tableRowItem)
            this.addView(
            participantViewBinding.root,
            TableLayout.LayoutParams(TableLayout.LayoutParams.MATCH_PARENT, TableLayout.LayoutParams.MATCH_PARENT, 1F / participants.size)
            )

            } else {
            if (count % 2 != 0) {
            participantViewBinding = ParticipantViewItemBinding.inflate(inflater, this, true)
            participantViewBinding.item = item.wrapper
            participantViewBinding.lifecycleOwner = lifecycleOwner

            rowList.add(participantViewBinding.tableRowItem)
            this.addView(
            participantViewBinding.root,
            TableLayout.LayoutParams(
            TableLayout.LayoutParams.MATCH_PARENT,
            TableLayout.LayoutParams.MATCH_PARENT,
            1F / participants.size
            )
            )
            } else {
            val oldRow = rowList.last()

            participantViewBinding = ParticipantViewItemBinding.inflate(inflater, oldRow, true)
            participantViewBinding.item = item.wrapper
            participantViewBinding.lifecycleOwner = lifecycleOwner

            oldRow.addView(
            participantViewBinding.root,
            TableLayout.LayoutParams(
            TableLayout.LayoutParams.MATCH_PARENT,
            TableLayout.LayoutParams.MATCH_PARENT,
            1F / participants.size
            )
            )
            }
            }*/
        }

    }
}