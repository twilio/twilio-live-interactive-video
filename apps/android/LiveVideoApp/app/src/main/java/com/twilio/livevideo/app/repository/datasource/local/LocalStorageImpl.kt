package com.twilio.livevideo.app.repository.datasource.local

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey

class LocalStorageImpl(context: Context) : LocalStorage {

    private val sharedPreferences: SharedPreferences

    init {
        val masterKey =
            MasterKey.Builder(context).setKeyScheme(MasterKey.KeyScheme.AES256_GCM).build()

        sharedPreferences = EncryptedSharedPreferences.create(
            context,
            SHARED_PREFERENCES_FILE_NAME,
            masterKey,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        )
    }

    override fun putStringData(key: String, value: String) {
        with(sharedPreferences.edit()) {
            putString(key, value)
            apply()
        }
    }

    override fun getStringData(key: String): String? {
        with(sharedPreferences) {
            return getString(key, null)
        }
    }

    companion object {
        private const val SHARED_PREFERENCES_FILE_NAME = "secret_shared_prefs"
    }
}