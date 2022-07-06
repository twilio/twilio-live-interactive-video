package com.twilio.livevideo.app.repository.datasource.local

interface LocalStorage {

    fun putStringData(key: String, value: String)

    fun getStringData(key: String): String?

    fun clearData()

}