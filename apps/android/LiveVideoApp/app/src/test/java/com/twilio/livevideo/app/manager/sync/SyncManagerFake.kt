package com.twilio.livevideo.app.manager.sync

import android.content.Context
import androidx.lifecycle.LifecycleOwner
import com.twilio.sync.ErrorInfo
import org.mockito.kotlin.mock
import javax.inject.Inject

class SyncManagerFake @Inject constructor(context: Context?) : SyncManager(context, mock(), mock(), mock(), mock()) {

    override fun connect(
        lifecycleOwner: LifecycleOwner,
        accessToken: String,
        userIdentity: String,
        hasUserDocument: Boolean,
        onComplete: ((ErrorInfo?) -> Unit)?
    ) {
        // DO NOTHING
    }
}