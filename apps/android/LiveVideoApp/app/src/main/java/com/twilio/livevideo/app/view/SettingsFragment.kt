package com.twilio.livevideo.app.view

import android.os.Bundle
import android.view.Menu
import android.view.View
import androidx.navigation.fragment.findNavController
import androidx.preference.Preference
import androidx.preference.PreferenceFragmentCompat
import com.twilio.live.player.Player
import com.twilio.livevideo.app.BuildConfig
import com.twilio.livevideo.app.R
import com.twilio.livevideo.app.manager.AuthenticatorManager
import com.twilio.sync.SyncClient
import com.twilio.video.Video
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class SettingsFragment : PreferenceFragmentCompat() {

    @Inject
    lateinit var authenticatorManager: AuthenticatorManager

    override fun onCreatePreferences(savedInstanceState: Bundle?, rootKey: String?) {
        setPreferencesFromResource(R.xml.fragment_settings, rootKey)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setHasOptionsMenu(true)
        setupPreferenceUI()
    }

    override fun onPrepareOptionsMenu(menu: Menu) {
        val item = menu.findItem(R.id.settingsFragment)
        item.isVisible = false
    }

    private fun setupPreferenceUI() {
        findPreference<Preference>(PREF_VERSION_ID)?.summary =
            "${BuildConfig.VERSION_NAME} (${BuildConfig.VERSION_CODE})"

        findPreference<Preference>(PREF_VIDEO_VERSION_ID)?.summary = Video.getVersion()

        findPreference<Preference>(PREF_PLAYER_VERSION_ID)?.summary = Player.version

        findPreference<Preference>(PREF_SYNC_VERSION_ID)?.summary = SyncClient.getSdkVersion()

        findPreference<Preference>(PREF_SIGN_OUT_ID)?.setOnPreferenceClickListener {
            authenticatorManager.clearCredentials()
            findNavController().navigate(SettingsFragmentDirections.actionSettingsFragmentToSignInFragment())
            true
        }
    }

    companion object {
        private const val PREF_VERSION_ID = "pref_version_name"
        private const val PREF_PLAYER_VERSION_ID = "pref_player_library_version"
        private const val PREF_VIDEO_VERSION_ID = "pref_video_library_version"
        private const val PREF_SYNC_VERSION_ID = "pref_sync_library_version"
        private const val PREF_SIGN_OUT_ID = "pref_logout"
    }
}