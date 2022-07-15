package com.twilio.livevideo.app.view

import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class StreamFragmentFake : StreamFragment() {

    override fun setupViewModel() {
        viewModel.initViewState(args.viewRole)
    }
}