package com.twilio.livevideo.app.view

import android.os.Bundle
import android.view.View
import android.view.ViewTreeObserver
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.Toolbar
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.navigation.NavController
import androidx.navigation.fragment.NavHostFragment
import androidx.navigation.ui.AppBarConfiguration
import androidx.navigation.ui.setupWithNavController
import com.twilio.livevideo.app.R
import com.twilio.livevideo.app.manager.AuthenticatorManager
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import javax.inject.Inject

@AndroidEntryPoint
class MainActivity : AppCompatActivity() {

    @Inject
    lateinit var authenticatorManager: AuthenticatorManager

    private lateinit var navController: NavController

    lateinit var toolbar: Toolbar
    private var activityScope: CoroutineScope = CoroutineScope(Dispatchers.Main)

    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen()
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        setupStartDestination()
        setupToolbar()
        delaySplash()
    }


    private fun setupStartDestination() {
        val navHost =
            supportFragmentManager.findFragmentById(R.id.nav_host_fragment) as NavHostFragment
        navController = navHost.navController

        if (authenticatorManager.isPasscodeValid()) {
            val newGraph = navController.navInflater.inflate(R.navigation.main_graph)
            newGraph.setStartDestination(R.id.homeFragment)
            navController.graph = newGraph
        }
    }

    private fun setupToolbar() {
        val appBarConfig = AppBarConfiguration(TOP_LEVEL_SCREENS)
        toolbar = findViewById(R.id.toolbar)
        toolbar.setupWithNavController(navController, appBarConfig)
    }

    private fun delaySplash() {
        val content: View = findViewById(android.R.id.content)
        var dataReady = false

        //TODO: Remove once the design is approved.
        activityScope.launch {
            delay(1500)
            dataReady = true
        }

        content.viewTreeObserver.addOnPreDrawListener(
            object : ViewTreeObserver.OnPreDrawListener {
                override fun onPreDraw(): Boolean {
                    // Check if the initial data is ready.
                    return if (dataReady) {
                        content.viewTreeObserver.removeOnPreDrawListener(this)
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