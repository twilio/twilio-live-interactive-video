package com.twilio.livevideo.app.manager

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

    fun addParticipant(gridLayout: GridLayout, participantList: List<ParticipantStream>) {
        if (participants.isEmpty() && participantList.isEmpty()) return
        val updatedParticipantListUI = participantList.take(GRID_MAX_PARTICIPANTS_LIMIT)
        val participantListUI = participants.take(GRID_MAX_PARTICIPANTS_LIMIT)

        //If the list contains exactly the same elements and the same order, then return.
        if (participantListUI == updatedParticipantListUI) return

        participants.addAll(participantList)

        //New participants To Be Added
        updatedParticipantListUI.forEach { item ->
            addParticipantView(item, gridLayout, isVerticalModeEnabled())
        }
    }

    fun addParticipant(gridLayout: GridLayout, participant: ParticipantStream) {
        participants.add(participant)
        if (participants.size <= GRID_MAX_PARTICIPANTS_LIMIT) {
            val isVerticalModeEnabled = isVerticalModeEnabled()
            resizeExistingParticipantViews(isVerticalModeEnabled)
            addParticipantView(participant, gridLayout, isVerticalModeEnabled)
        }
    }

    fun removeParticipant(gridLayoutContainer: GridLayout, participantIdentity: String) {
        participants.indexOfFirst {
            it.identity == participantIdentity
        }.also { index ->
            if (index >= 0) {
                val item = participants.removeAt(index)
                val isVerticalModeEnabled = isVerticalModeEnabled()
                val indexBinding: Int = bindings.indexOfFirst { binding ->
                    binding.item?.let {
                        item.identity == it.identity
                    } ?: false
                }.also { indexBinding ->
                    if (indexBinding >= 0) {
                        val itemBinding = bindings[indexBinding]
                        gridLayoutContainer.removeView(itemBinding.root)
                        bindings.removeAt(indexBinding)
                        resizeExistingParticipantViews(isVerticalModeEnabled)
                    }
                }
                if (indexBinding >= 0 && participants.size >= GRID_MAX_PARTICIPANTS_LIMIT) {
                    addParticipantView(participants[GRID_MAX_PARTICIPANTS_LIMIT - 1], gridLayoutContainer, isVerticalModeEnabled)
                }
            }
        }
    }

    fun updateDominantSpeaker(gridLayoutContainer: GridLayout, participantIdentity: String?) {
        participants.firstOrNull { it.isDominantSpeaker }?.apply { this.isDominantSpeaker = false }
        participantIdentity?.also { newIdentity ->
            participants.indexOfFirst {
                it.identity == newIdentity
            }.also { dominantSpeakerIndex ->
                val dominantSpeaker = participants[dominantSpeakerIndex]
                dominantSpeaker.isDominantSpeaker = true

                if (dominantSpeakerIndex + 1 > GRID_MAX_PARTICIPANTS_LIMIT) {
                    participants.take(GRID_MAX_PARTICIPANTS_LIMIT).drop(1).minByOrNull {
                        it.dominantSpeakerStartTime
                    }?.also { oldestDominantSpeakerUI ->
                        participants.indexOfFirst {
                            it.identity == oldestDominantSpeakerUI.identity
                        }.also { oldestDominantSpeakerIndex ->
                            if (oldestDominantSpeakerIndex >= 0) {
                                val oldestDominantSpeaker = participants[oldestDominantSpeakerIndex]
                                bindings.indexOfFirst {
                                    it.item?.let { item ->
                                        item.identity == oldestDominantSpeaker.identity
                                    } ?: false
                                }.also { bindingIndex ->
                                    if (bindingIndex < 0) return
                                    val binding = bindings[bindingIndex]
                                    val viewIndex = gridLayoutContainer.indexOfChild(binding.root)
                                    gridLayoutContainer.removeViewAt(viewIndex)

                                    addParticipantView(dominantSpeaker, gridLayoutContainer, isVerticalModeEnabled(), viewIndex, bindingIndex)
                                }

                                participants[oldestDominantSpeakerIndex] = participants[dominantSpeakerIndex]
                                participants.removeAt(dominantSpeakerIndex)
                                participants.add(GRID_MAX_PARTICIPANTS_LIMIT, oldestDominantSpeakerUI)

                            }
                        }
                    }
                }
            }
        }
    }

    fun getOffScreenCount(): Int {
        return participants.size - GRID_MAX_PARTICIPANTS_LIMIT
    }

    private fun addParticipantView(
        item: ParticipantStream,
        gridLayout: GridLayout,
        isVerticalModeEnabled: Boolean,
        indexView: Int = -1,
        indexBinding: Int = -1
    ) {
        ViewTreeLifecycleOwner.get(gridLayout)?.also { lifecycleOwner ->
            val inflater = LayoutInflater.from(gridLayout.context)
            val participantViewBinding: ParticipantViewItemBinding =
                createParticipantView(inflater, item, gridLayout, isVerticalModeEnabled, lifecycleOwner, indexView)
            if (indexBinding < 0)
                bindings.add(participantViewBinding)
            else
                bindings[indexBinding] = participantViewBinding
        }
    }

    private fun resizeExistingParticipantViews(isVerticalModeEnabled: Boolean) {
        bindings.forEach {
            toggleGridMode((it.root.layoutParams as GridLayout.LayoutParams), isVerticalModeEnabled)
        }
    }


    private fun createParticipantView(
        inflater: LayoutInflater,
        item: ParticipantStream,
        parentView: ViewGroup,
        isVerticalModeEnabled: Boolean,
        lifecycleOwner: LifecycleOwner,
        indexView: Int = -1
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


        parentView.addView(
            participantViewBinding.root,
            indexView,
            participantViewBinding.root.layoutParams?.apply {
                toggleGridMode((this as GridLayout.LayoutParams), isVerticalModeEnabled)
            }
        )


        return participantViewBinding
    }

    private fun toggleGridMode(layoutParams: GridLayout.LayoutParams, isVerticalModeEnabled: Boolean) {
        layoutParams.columnSpec = if (isVerticalModeEnabled) {
            GridLayout.spec(GridLayout.UNDEFINED, 2, 1F)
        } else {
            GridLayout.spec(GridLayout.UNDEFINED, 1, 1F)
        }
    }

    private fun isVerticalModeEnabled(): Boolean = participants.size <= VERTICAL_MODE_LIMIT

    companion object {
        private const val GRID_MAX_PARTICIPANTS_LIMIT = 4
        private const val VERTICAL_MODE_LIMIT = 3
    }
}