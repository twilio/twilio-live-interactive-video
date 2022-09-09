package com.twilio.livevideo.app.manager.sync

import com.twilio.sync.ErrorInfo

sealed class SyncViewEvent {

    data class OnError(val error: ErrorInfo) : SyncViewEvent()
    data class OnMapItemAdded(val syncUser: SyncUser) : SyncViewEvent()
    data class OnMapItemRemoved(val syncUser: SyncUser) : SyncViewEvent()
    object OnDocumentSpeakerInvite : SyncViewEvent()

}
