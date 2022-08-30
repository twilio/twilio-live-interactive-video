package com.twilio.livevideo.app.repository.model

import com.google.gson.annotations.SerializedName

data class VerifyPasscodeResponse(
    @SerializedName("verified")
    val isVerified: Boolean = false
) : BaseResponse()

data class CreateStreamResponse(
    @SerializedName("token")
    val token: String = ""
) : BaseResponse()

data class DeleteStreamResponse(
    @SerializedName("deleted")
    val deleted: Boolean = false
) : BaseResponse()

data class JoinStreamAsSpeakerResponse(
    @SerializedName("token")
    val token: String = ""
) : BaseResponse()

data class JoinStreamAsViewerResponse(
    @SerializedName("token")
    val token: String = ""
) : BaseResponse()

data class ViewerConnectedToPlayerResponse(
    @SerializedName("success")
    val isSuccess: Boolean
) : BaseResponse()

data class RaiseHandResponse(
    @SerializedName("sent")
    val isSent: Boolean
) : BaseResponse()

data class RemoveSpeakerResponse(
    @SerializedName("removed")
    val isRemoved: Boolean = false
) : BaseResponse()

data class SendSpeakerInviteResponse(
    @SerializedName("sent")
    val isSent: Boolean
) : BaseResponse()

data class ErrorResponse(

    @SerializedName("message")
    var message: String,

    @SerializedName("explanation")
    var explanation: String

)

abstract class BaseResponse(
    @SerializedName("error")
    var error: ErrorResponse? = null,

    var isApiResponseSuccess: Boolean = false,

    var code: Int = 0
)