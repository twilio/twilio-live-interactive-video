package com.twilio.livevideo.app.view

import android.os.Bundle
import android.view.View
import android.view.ViewTreeObserver
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.Toolbar
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.navigation.findNavController
import androidx.navigation.ui.AppBarConfiguration
import androidx.navigation.ui.setupWithNavController
import com.twilio.livevideo.app.R
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@AndroidEntryPoint
class MainActivity : AppCompatActivity() {
    private var activityScope: CoroutineScope = CoroutineScope(Dispatchers.Main)

    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen()
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        delaySplash()
    }

    private fun setupToolbar() {
        val navController = findNavController(R.id.nav_host_fragment)
        val appBarConfig = AppBarConfiguration(TOP_LEVEL_SCREENS)
        val toolbar: Toolbar = findViewById(R.id.toolbar)
        toolbar.setupWithNavController(navController, appBarConfig)
    }

    private fun delaySplash() {
        val content: View = findViewById(android.R.id.content)
        var dataReady = false

        //TODO: Remove once the design is approved.
        activityScope.launch {
            delay(1000)
            dataReady = true
        }

        content.viewTreeObserver.addOnPreDrawListener(
            object : ViewTreeObserver.OnPreDrawListener {
                override fun onPreDraw(): Boolean {
                    // Check if the initial data is ready.
                    return if (dataReady) {
                        content.viewTreeObserver.removeOnPreDrawListener(this)
                        setupToolbar()
                        true
                    } else {
                        false
                    }
                }
            }
        )
    }

    override fun onPause() {
        super.onPause()
        activityScope.cancel()
    }

    companion object {
        private val TOP_LEVEL_SCREENS: Set<Int> = setOf(
            R.id.signInFragment,
            R.id.homeFragment
        )
    }
}