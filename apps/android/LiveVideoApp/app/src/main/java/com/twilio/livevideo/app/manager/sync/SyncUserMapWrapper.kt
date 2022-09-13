package com.twilio.livevideo.app.manager.sync

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.twilio.sync.ErrorInfo
import com.twilio.sync.EventContext
import com.twilio.sync.SuccessListener
import com.twilio.sync.SyncClient
import com.twilio.sync.SyncMap
import com.twilio.sync.SyncMapObserver
import com.twilio.sync.SyncMapPaginator
import com.twilio.sync.SyncOptions
import org.json.JSONObject

class SyncUserMapWrapper constructor(private var uniqueName: String = "") : SyncObject {

    private var userList: MutableList<SyncUser>? = null

    private val _onStateEvent: MutableLiveData<SyncViewEvent?> =
        MutableLiveData<SyncViewEvent?>(null)
    val onStateEvent: LiveData<SyncViewEvent?>
        get() {
            val event = _onStateEvent
            _onStateEvent.value = null
            return event
        }

    private val syncMapObserver: SyncMapObserver = object : SyncMapObserver() {
        override fun onItemAdded(context: EventContext?, item: SyncMap.Item?) {
            item?.apply {
                val syncUser = SyncUser(this)
                userList?.add(syncUser)
                _onStateEvent.postValue(SyncViewEvent.OnMapItemAdded(syncUser))
            }
        }

        override fun onItemRemoved(context: EventContext?, itemKey: String?, previousItemData: JSONObject?) {
            userList?.indexOfFirst {
                it.identity == itemKey
            }?.apply {
                if (this >= 0) {
                    userList?.removeAt(this)?.also {
                        _onStateEvent.postValue(SyncViewEvent.OnMapItemRemoved(it))
                    }
                }
            }
        }

        override fun onErrorOccurred(error: ErrorInfo?) {
            disconnect()
        }
    }

    override fun connect(client: SyncClient, completion: (ErrorInfo?) -> Unit) {
        client.openMap(SyncOptions.create().withUniqueName(uniqueName), syncMapObserver, object : SuccessListener<SyncMap> {
            override fun onSuccess(result: SyncMap?) {
                result?.apply {
                    val queryOptions: SyncMap.QueryOptions = queryOptions().withPageSize(100)

                    this.queryItems(queryOptions, object : SuccessListener<SyncMapPaginator> {
                        override fun onSuccess(result: SyncMapPaginator?) {
                            userList = result?.items?.map {
                                SyncUser(it)
                            }?.toMutableList()

                            completion(null)
                        }

                        override fun onError(error: ErrorInfo?) {
                            completion.invoke(error)
                        }
                    })
                }

                completion.invoke(null)
            }

            override fun onError(error: ErrorInfo?) {
                completion.invoke(error)
            }
        })
    }

    override fun disconnect() {
        userList?.clear()
        userList = null
    }
}

data class SyncUser(private val item: SyncMap.Item) {
    var identity: String? = null
    var isHost: Boolean = false

    init {
        identity = item.key
        isHost = if (item.data.has(HOST_KEY)) item.data[HOST_KEY] as Boolean else false
    }

    companion object {
        private const val HOST_KEY = "host"
    }
}