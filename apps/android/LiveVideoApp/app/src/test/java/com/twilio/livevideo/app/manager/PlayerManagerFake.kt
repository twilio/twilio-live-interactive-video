package com.twilio.livevideo.app.manager

import android.content.Context
import javax.inject.Inject

class PlayerManagerFake @Inject constructor(context: Context?) : PlayerManager(context) {

    var connectUnit : (() -> Unit)? = null

}