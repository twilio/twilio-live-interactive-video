package com.twilio.livevideo.app.manager.sync

import com.twilio.sync.ErrorInfo
import com.twilio.sync.SyncClient

interface SyncObject {

    fun connect(client: SyncClient, completion: ((ErrorInfo?) -> Unit))

    fun disconnect()

}