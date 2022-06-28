package com.twilio.livevideo.app.repository.datasource.local

class LocalStorageImplFake() : LocalStorage {

    private val sharedPreferences: MutableMap<String, String> = mutableMapOf()

    override fun putStringData(key: String, value: String) {
        sharedPreferences[key] = value
    }

    override fun getStringData(key: String): String? = sharedPreferences[key]

}