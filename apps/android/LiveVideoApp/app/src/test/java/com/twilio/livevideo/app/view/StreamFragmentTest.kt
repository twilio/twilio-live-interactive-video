package com.twilio.livevideo.app.view

import android.os.Bundle
import androidx.arch.core.executor.testing.InstantTaskExecutorRule
import androidx.lifecycle.Observer
import com.twilio.live.player.PlayerState
import com.twilio.livevideo.app.launchFragmentInHiltContainer
import com.twilio.livevideo.app.manager.PlayerManager
import com.twilio.livevideo.app.manager.PlayerManagerFake
import com.twilio.livevideo.app.repository.datasource.remote.LiveVideoAPIService
import com.twilio.livevideo.app.repository.model.JoinStreamAsViewerResponse
import com.twilio.livevideo.app.util.MainCoroutineScopeRule
import com.twilio.livevideo.app.viewmodel.CommonStreamViewModel
import com.twilio.livevideo.app.viewmodel.StreamViewEvent
import com.twilio.livevideo.app.viewmodel.StreamViewModel
import com.twilio.livevideo.app.viewstate.ViewRole
import dagger.hilt.android.testing.HiltAndroidRule
import dagger.hilt.android.testing.HiltAndroidTest
import dagger.hilt.android.testing.HiltTestApplication
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.runTest
import org.junit.Assert
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.Mock
import org.mockito.MockitoAnnotations
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import retrofit2.Response
import javax.inject.Inject

@HiltAndroidTest
@ExperimentalCoroutinesApi
@RunWith(RobolectricTestRunner::class)
@Config(application = HiltTestApplication::class, sdk = [28])
class StreamFragmentTest {

    @ExperimentalCoroutinesApi
    @get:Rule
    val coroutineScope = MainCoroutineScopeRule()

    @get:Rule
    var hiltRule = HiltAndroidRule(this)

    @get:Rule
    var mInstantTaskExecutorRule = InstantTaskExecutorRule()

    private lateinit var viewModel: StreamViewModel
    private lateinit var commonViewModel: CommonStreamViewModel

    @Mock
    private lateinit var playerEventObserver: Observer<in PlayerManager.OnStateCallback?>
    private var screenEventObserver = mock<Observer<in StreamViewEvent?>>()

    @Inject
    lateinit var liveVideoAPIService: LiveVideoAPIService

    lateinit var playerManager: PlayerManagerFake

    @Before
    fun setup() {
        MockitoAnnotations.openMocks(this)
        hiltRule.inject()
        init()
    }

    private fun init() {
        val bundle = Bundle().apply {
            putParcelable("viewRole", ViewRole.Viewer)
        }
        launchFragmentInHiltContainer<StreamFragmentFake>(fragmentArgs = bundle) {
            this@StreamFragmentTest.viewModel = this.viewModel
            this@StreamFragmentTest.commonViewModel = this.commonViewModel
            this@StreamFragmentTest.playerManager = this.playerManager as PlayerManagerFake
        }

        viewModel.screenEvent.observeForever(screenEventObserver)
        playerManager.onStateEvent.observeForever(playerEventObserver)
    }

    @Test
    fun `join to stream with valid event name`() {
        runTest {
            //GIVEN
            val token = "token1"
            val eventName = "EventName"

            val responseBody = JoinStreamAsViewerResponse(token).apply {
                this.isApiResponseSuccess = true
                this.code = 202
            }
            val response = Response.success(responseBody)
            whenever(liveVideoAPIService.joinStreamAsViewer("", eventName)).thenReturn(
                response
            )
            playerManager.connectUnit = {
                playerManager.onStateChanged(mock(), PlayerState.PLAYING)
            }

            //WHEN
            verify(playerEventObserver).onChanged(null)
            verify(screenEventObserver).onChanged(null)
            Assert.assertEquals(true, viewModel.viewState.value?.isLoading)
            assertLoadingSpinnerIsDisplayed()
            viewModel.joinStreamAsViewer(eventName)

            //THEN
            verify(screenEventObserver).onChanged(StreamViewEvent.OnConnectViewer(token))
            verify(playerEventObserver).onChanged(PlayerManager.OnStateCallback.OnPlaying)
            Assert.assertEquals(false, viewModel.viewState.value?.isLoading)
            assertLoadingSpinnerIsNotDisplayed()
        }
    }

}