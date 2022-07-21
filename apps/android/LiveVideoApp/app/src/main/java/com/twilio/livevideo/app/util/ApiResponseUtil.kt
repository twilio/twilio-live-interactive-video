package com.twilio.livevideo.app.util

import com.google.gson.Gson
import com.google.gson.JsonSyntaxException
import com.twilio.livevideo.app.repository.model.BaseResponse
import com.twilio.livevideo.app.repository.model.ErrorResponse
import okhttp3.ResponseBody
import timber.log.Timber

class ApiResponseUtil {

    companion object {
        fun parseErrorBody(
            gson: Gson,
            responseBody: ResponseBody?,
            result: BaseResponse,
            mappingClass: Class<out BaseResponse>
        ) {
            try {
                gson.fromJson(responseBody?.charStream(), mappingClass)
                    ?.apply {
                        result.error = this.error
                    }
            } catch (ex: JsonSyntaxException) {
                Timber.e(ex.message)
                val explanation = if (result.code == 404)
                    ""
                else
                    ex.message ?: "JsonSyntaxException"
                result.error = ErrorResponse("Error - ${result.code}", explanation)
            }
        }
    }

}