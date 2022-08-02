package com.twilio.livevideo.app.repository

import com.twilio.livevideo.app.manager.AuthenticatorManager
import com.twilio.livevideo.app.repository.datasource.remote.RemoteStorage
import com.twilio.livevideo.app.repository.model.CreateStreamResponse
import com.twilio.livevideo.app.repository.model.DeleteStreamResponse
import com.twilio.livevideo.app.repository.model.JoinStreamAsSpeakerResponse
import com.twilio.livevideo.app.repository.model.JoinStreamAsViewerResponse
import com.twilio.livevideo.app.repository.model.VerifyPasscodeResponse
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import javax.inject.Inject

class LiveVideoRepository @Inject constructor(
    private val remoteStorage: RemoteStorage,
    private val authenticator: AuthenticatorManager,
    private val dispatcher: CoroutineDispatcher
) {

    suspend fun verifyPasscode(passcode: String, userName: String): VerifyPasscodeResponse =
        withContext(Dispatchers.IO) {
            val response = remoteStorage.verifyPasscode(passcode)
            if (response.isApiResponseSuccess) {
                authenticator.storeCredentials(passcode, userName)
            }
            response
        }

    suspend fun joinStreamAsViewer(
        streamName: String
    ): JoinStreamAsViewerResponse = withContext(dispatcher) {
        remoteStorage.joinStreamAsViewer(authenticator.getUserName(), streamName)
    }

    suspend fun createStream(
        streamName: String
    ): CreateStreamResponse = withContext(dispatcher) {
        remoteStorage.createStream(authenticator.getUserName(), streamName)
    }

    suspend fun deleteStream(
        streamName: String
    ): DeleteStreamResponse = withContext(dispatcher) {
        remoteStorage.deleteStream(streamName)
    }

    suspend fun joinStreamAsSpeaker(
        streamName: String
    ): JoinStreamAsSpeakerResponse = withContext(dispatcher) {
        remoteStorage.joinStreamAsSpeaker(authenticator.getUserName(), streamName)
    }

}