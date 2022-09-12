package com.twilio.livevideo.app.manager.sync

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.twilio.sync.ErrorInfo
import com.twilio.sync.EventContext
import com.twilio.sync.SuccessListener
import com.twilio.sync.SyncClient
import com.twilio.sync.SyncDocument
import com.twilio.sync.SyncDocumentObserver
import com.twilio.sync.SyncOptions
import org.json.JSONObject
import timber.log.Timber

class SyncDocumentWrapper constructor(var uniqueName: String = "") : SyncObject {

    private var document: SyncDocument? = null

    private val _onStateEvent: MutableLiveData<SyncViewEvent?> =
        MutableLiveData<SyncViewEvent?>(null)
    val onStateEvent: LiveData<SyncViewEvent?>
        get() {
            val event = _onStateEvent
            _onStateEvent.value = null
            return event
        }

    private val syncDocumentObserver: SyncDocumentObserver = object : SyncDocumentObserver() {
        override fun onUpdated(context: EventContext?, data: JSONObject?, previousData: JSONObject?) {
            super.onUpdated(context, data, previousData)

            data?.apply {
                val inviteKey = "speaker_invite"
                if (has(inviteKey)) {
                    data.getBoolean(inviteKey).also {
                        Timber.d("onUpdated $it")
                        if (it) _onStateEvent.postValue(SyncViewEvent.OnDocumentSpeakerInvite)
                    }
                }
            }
        }

        override fun onErrorOccurred(error: ErrorInfo?) {
            disconnect()
            error?.apply { _onStateEvent.postValue(SyncViewEvent.OnError(this)) }
        }
    }

    override fun connect(client: SyncClient, completion: ((ErrorInfo?) -> Unit)) {

        client.openDocument(SyncOptions.create().withUniqueName(uniqueName), syncDocumentObserver, object : SuccessListener<SyncDocument> {
            override fun onSuccess(result: SyncDocument?) {
                document = result
                completion.invoke(null)
            }

            override fun onError(error: ErrorInfo?) {
                completion.invoke(error)
            }
        })

    }

    override fun disconnect() {
        document = null
    }
}
