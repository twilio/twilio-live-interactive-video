package com.twilio.livevideo.app.manager

import android.content.Context
import android.view.LayoutInflater
import android.view.ViewGroup
import android.widget.GridLayout
import androidx.core.view.doOnAttach
import androidx.core.view.doOnDetach
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.ViewTreeLifecycleOwner
import com.twilio.livevideo.app.databinding.ParticipantViewItemBinding
import com.twilio.livevideo.app.manager.room.ParticipantStream
import timber.log.Timber

class GridManager {
    private val participants: MutableList<ParticipantStream> = mutableListOf()
    private val bindings: MutableList<ParticipantViewItemBinding> = mutableListOf()

    fun getOffScreenCount(): Int {
        return participants.size - GRID_MAX_PARTICIPANTS_LIMIT
    }

    fun updateParticipants(context: Context, gridLayout: GridLayout, updatedParticipantList: List<ParticipantStream>) {
        if (participants.isEmpty() && updatedParticipantList.isEmpty()) return
        val updatedParticipantListUI = updatedParticipantList.take(GRID_MAX_PARTICIPANTS_LIMIT)

        //If the list contains exactly the same elements and the same order, then return.
        if (participants == updatedParticipantListUI) return

        //Remove disconnected participants
        removeDisconnectedParticipants(gridLayout, updatedParticipantListUI)

        val participantsToBeAdded = updatedParticipantListUI.minus(participants.toSet())
        val newSize = participants.size + participantsToBeAdded.size
        val isVerticalModeEnabled = newSize <= VERTICAL_MODE_LIMIT

        //Resize existing participants views.
        resizeExistingParticipantViews(isVerticalModeEnabled)

        // Add new participants
        addNewParticipants(context, gridLayout, participantsToBeAdded, isVerticalModeEnabled)
    }

    private fun removeDisconnectedParticipants(gridLayout: GridLayout, updatedParticipantList: List<ParticipantStream>) {
        if (participants.isNotEmpty()) {
            //participantsToBeRemoved
            participants.minus(updatedParticipantList.toSet()).forEach { participantToRemove ->
                participants.firstOrNull {
                    it.identity == participantToRemove.identity
                }?.also { participantStream ->
                    bindings.firstOrNull { binding ->
                        binding.item?.let {
                            participantStream.identity == it.identity
                        } ?: false
                    }?.also { binding ->
                        gridLayout.removeView(binding.root)
                        bindings.remove(binding)
                    }
                    participants.remove(participantStream)
                }
            }
        }
    }

    private fun resizeExistingParticipantViews(isVerticalModeEnabled: Boolean) {
        bindings.forEach {
            toggleGridMode((it.root.layoutParams as GridLayout.LayoutParams), isVerticalModeEnabled)
        }
    }

    private fun addNewParticipants(
        context: Context,
        gridLayout: GridLayout,
        participantsToBeAdded: List<ParticipantStream>,
        isVerticalModeEnabled: Boolean
    ) {
        ViewTreeLifecycleOwner.get(gridLayout)?.also { lifecycleOwner ->
            val inflater = LayoutInflater.from(context)
            //New participants To Be Added
            var limit = GRID_MAX_PARTICIPANTS_LIMIT - participants.size
            if (limit < 0) limit = 0
            participantsToBeAdded.take(limit).forEach { item ->
                val participantViewBinding: ParticipantViewItemBinding =
                    createParticipantView(inflater, item, gridLayout, isVerticalModeEnabled, lifecycleOwner)
                participants.add(item)
                bindings.add(participantViewBinding)
            }
        }
    }

    private fun createParticipantView(
        inflater: LayoutInflater,
        item: ParticipantStream,
        parentView: ViewGroup?,
        isVerticalModeEnabled: Boolean,
        lifecycleOwner: LifecycleOwner,
    ): ParticipantViewItemBinding {

        val participantViewBinding = ParticipantViewItemBinding.inflate(inflater, parentView, false)
        participantViewBinding.item = item
        participantViewBinding.lifecycleOwner = lifecycleOwner

        participantViewBinding.root.doOnAttach {
            Timber.d("doOnAttach ${item.identity}")
            it.doOnDetach {
                Timber.d("doOnDetach ${item.identity}")
                item.videoTrack?.removeSink(participantViewBinding.videoView)
                lifecycleOwner.lifecycle.removeObserver(item)
            }
        }

        parentView?.apply {
            addView(
                participantViewBinding.root,
                participantViewBinding.root.layoutParams.apply {
                    toggleGridMode((this as GridLayout.LayoutParams), isVerticalModeEnabled)
                }
            )
        }

        return participantViewBinding
    }

    private fun toggleGridMode(layoutParams: GridLayout.LayoutParams, isVerticalModeEnabled: Boolean) {
        layoutParams.columnSpec = if (isVerticalModeEnabled) {
            GridLayout.spec(GridLayout.UNDEFINED, 2, 1F)
        } else {
            GridLayout.spec(GridLayout.UNDEFINED, 1, 1F)
        }
    }

    companion object {
        private const val GRID_MAX_PARTICIPANTS_LIMIT = 4
        private const val VERTICAL_MODE_LIMIT = 3

        fun switchParticipants(list: MutableList<ParticipantStream>, participant: ParticipantStream): Boolean {
            list.indexOf(participant).also { index ->
                if (index + 1 > GRID_MAX_PARTICIPANTS_LIMIT) {
                    //Take the first N limit participants and skip the first element which is the local participant.
                    list.take(GRID_MAX_PARTICIPANTS_LIMIT).drop(1).maxByOrNull {
                        it.dominantSpeakerStartTime
                    }?.also { oldestDominantSpeaker ->
                        val oldestDominantSpeakerIndex = list.indexOf(oldestDominantSpeaker)
                        list[oldestDominantSpeakerIndex] = participant
                        list[index] = oldestDominantSpeaker
                        return true
                    }
                }
            }
            return false
        }
    }
}