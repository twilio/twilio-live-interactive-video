package com.twilio.livevideo.app.repository.model

import com.google.gson.annotations.SerializedName

data class VerifyPasscodeResponse(
    @SerializedName("verified")
    val isVerified: Boolean? = null
) : BaseResponse()

data class CreateStreamResponse(
    @SerializedName("token")
    val token: String? = null
) : BaseResponse()

data class JoinStreamAsSpeakerResponse(
    @SerializedName("token")
    val token: String? = null
) : BaseResponse()

data class ViewerConnectedToPlayerResponse(
    @SerializedName("success")
    val isSuccess: Boolean? = null
) : BaseResponse()

data class RaiseHandResponse(
    @SerializedName("sent")
    val isSent: Boolean? = null
) : BaseResponse()

data class RemoveSpeakerResponse(
    @SerializedName("removed")
    val isRemoved: Boolean? = null
) : BaseResponse()

data class SendSpeakerInviteResponse(
    @SerializedName("sent")
    val isSent: Boolean? = null
) : BaseResponse()

data class ErrorResponse(

    @SerializedName("message")
    val message: String,

    @SerializedName("explanation")
    val explanation: String

)

abstract class BaseResponse(

    @SerializedName("error")
    var error: ErrorResponse? = null,

    var isApiResponseSuccess: Boolean = false,

    var code: Int = 0
)