package com.twilio.livevideo.app.repository.model

import com.google.gson.annotations.SerializedName

data class RaiseHandParameters(
    @SerializedName("user_identity")
    val userIdentity: String = "",
    @SerializedName("stream_name")
    val streamName: String = "",
    @SerializedName("hand_raised")
    val handRaised: Boolean = false
)