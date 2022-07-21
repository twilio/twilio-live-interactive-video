package com.twilio.livevideo.app.view

import com.twilio.livevideo.app.viewstate.ViewRole
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class StreamFragmentFake : StreamFragment() {

    override fun initializedRole(viewRole: ViewRole) {
        //DO NOTHING
    }

}