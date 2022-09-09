package com.twilio.livevideo.app.manager.sync

import android.content.Context
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LiveData
import com.twilio.livevideo.app.custom.BaseLifeCycleComponent
import com.twilio.sync.ErrorInfo
import com.twilio.sync.SyncClient
import javax.inject.Inject

class SyncManager @Inject constructor(
    private val context: Context?
) : BaseLifeCycleComponent(), SyncClient.SyncClientListener {

    private var syncObjects: MutableList<out SyncObject>? = null

    private var syncClient: SyncClient? = null

    private var userDocument: SyncDocumentWrapper = SyncDocumentWrapper()
    private var speakersMap: SyncMapWrapper = SyncMapWrapper("speakers")
    private var viewersMap: SyncMapWrapper = SyncMapWrapper("viewers")
    private var raisedHandsMap: SyncMapWrapper = SyncMapWrapper("raised_hands")

    val isConnected: Boolean
        get() = syncClient != null

    val documentLiveData: LiveData<SyncViewEvent?>
        get() = userDocument.onStateEvent
    val speakersMapLiveData: LiveData<SyncViewEvent?>
        get() = speakersMap.onStateEvent
    val viewersMapLiveData: LiveData<SyncViewEvent?>
        get() = viewersMap.onStateEvent
    val raisedHandsMapLiveData: LiveData<SyncViewEvent?>
        get() = raisedHandsMap.onStateEvent

    fun connect(
        lifecycleOwner: LifecycleOwner,
        accessToken: String,
        userIdentity: String,
        hasUserDocument: Boolean,
        onComplete: ((ErrorInfo?) -> Unit)? = null
    ) {
        context?.apply {
            this@SyncManager.init(lifecycleOwner.lifecycle)

            syncObjects = mutableListOf<SyncObject>(speakersMap, viewersMap, raisedHandsMap).also { objectsList ->
                if (hasUserDocument) {
                    userDocument.uniqueName = "user-$userIdentity"
                    objectsList.add(userDocument)
                }

                SyncClient.create(this, accessToken, SyncClient.Properties.defaultProperties()) { client ->
                    syncClient = client?.also { it.setListener(this@SyncManager) }

                    var connectedSyncObjects = 0
                    objectsList.forEach { syncObject ->
                        syncObject.connect(client) { error ->
                            if (error != null) {
                                disconnect()
                                onComplete?.invoke(error)
                                return@connect
                            } else {
                                connectedSyncObjects++
                                if (connectedSyncObjects == objectsList.size) {
                                    onComplete?.invoke(null)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    fun disconnect() {
        syncClient?.shutdown()
        syncClient = null
        syncObjects?.forEach { it.disconnect() }
        syncObjects = null
    }

    override fun onConnectionStateChanged(state: SyncClient.ConnectionState?) {
        when (state) {
            SyncClient.ConnectionState.CONNECTING -> {}
            SyncClient.ConnectionState.CONNECTED -> {}
            SyncClient.ConnectionState.DISCONNECTED -> {}
            SyncClient.ConnectionState.DENIED -> {}
            SyncClient.ConnectionState.ERROR -> {}
            SyncClient.ConnectionState.FATAL_ERROR -> {}
            null -> {}
        }
    }
}