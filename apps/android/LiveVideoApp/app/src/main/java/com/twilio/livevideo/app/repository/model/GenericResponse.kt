package com.twilio.livevideo.app.repository.model

import com.google.gson.annotations.SerializedName

data class GenericResponse(

    @SerializedName("verified")
    val isVerified: Boolean? = null,

    @SerializedName("success")
    val isSuccess: Boolean? = null,

    @SerializedName("sent")
    val isSent: Boolean? = null,

    @SerializedName("removed")
    val isRemoved: Boolean? = null,

    @SerializedName("token")
    val token: String? = null

) : BaseResponse()

data class ErrorResponse(

    @SerializedName("message")
    val message: String? = null,

    @SerializedName("explanation")
    val explanation: String? = null

)

abstract class BaseResponse(

    @SerializedName("error")
    var error: ErrorResponse? = null,

    var isApiResponseSuccess: Boolean = false,

    var code: Int = 0
)