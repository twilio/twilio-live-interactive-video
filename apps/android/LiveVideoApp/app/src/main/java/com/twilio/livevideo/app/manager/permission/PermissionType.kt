package com.twilio.livevideo.app.manager.permission

import android.Manifest.permission.*
import android.content.Context.MEDIA_PROJECTION_SERVICE
import android.os.Build
import androidx.annotation.RequiresApi

sealed class PermissionType(vararg val permissions: String) {

    @RequiresApi(Build.VERSION_CODES.S)
    object Bluetooth : PermissionType(BLUETOOTH_CONNECT)

    object Audio : PermissionType(RECORD_AUDIO)

    @RequiresApi(Build.VERSION_CODES.S)
    object AudioBluetooth : PermissionType(RECORD_AUDIO, BLUETOOTH_CONNECT)

    object CameraAudio : PermissionType(RECORD_AUDIO, CAMERA)

    object MediaProjection : PermissionType(MEDIA_PROJECTION_SERVICE)
}