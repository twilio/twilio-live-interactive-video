package com.twilio.livevideo.app.manager.permission

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.media.projection.MediaProjectionManager
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import java.lang.ref.WeakReference

class PermissionManager constructor(private val fragment: WeakReference<Fragment>) {
    private val requiredPermissions = mutableListOf<PermissionType>()
    private var rationale: String? = null
    private var callback: (Boolean, Int?, Intent?) -> Unit = { _, _, _ -> }

    private val permissionCheckMultiple =
        fragment.get()
            ?.registerForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) { grantResults ->
                sendResultAndCleanUp(grantResults)
            }

    private val permissionCheckSingle = fragment.get()
        ?.registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
            sendResultAndCleanUpSingle(
                Activity.RESULT_OK == result.resultCode,
                result.resultCode,
                result.data
            )
        }

    fun request(vararg permission: PermissionType): PermissionManager {
        requiredPermissions.addAll(permission)
        return this
    }

    fun rationale(description: String): PermissionManager {
        rationale = description
        return this
    }

    fun checkPermission(callback: (Boolean, Int?, Intent?) -> Unit) {
        this.callback = callback
        handlePermissionRequest()
    }

    private fun handlePermissionRequest() {
        fragment.get()?.let { fragment ->
            when {
                areAllPermissionsGranted(fragment) -> sendPositiveResult()
                shouldShowPermissionRationale(fragment) -> displayRationale(fragment)
                else -> requestPermissions(fragment)
            }
        }
    }

    private fun displayRationale(fragment: Fragment) {
        Toast.makeText(fragment.context, rationale, Toast.LENGTH_LONG).show()
    }

    private fun sendPositiveResult() {
        sendResultAndCleanUp(getPermissionList().associateWith { true })
    }

    private fun sendResultAndCleanUp(grantResults: Map<String, Boolean>) {
        callback(grantResults.all { it.value }, null, null)
        cleanUp()
    }

    private fun sendResultAndCleanUpSingle(granted: Boolean, resultCode: Int, data: Intent?) {
        callback(granted, resultCode, data)
        cleanUp()
    }

    private fun cleanUp() {
        requiredPermissions.clear()
        rationale = null
        callback = { _, _, _ -> }
    }

    private fun requestPermissions(fragment: Fragment) {
        val list = getPermissionList()
        if (list.size == 1 && list[0] == Context.MEDIA_PROJECTION_SERVICE) {
            fragment.activity?.apply {
                val mediaProjectionManager =
                    this.getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
                permissionCheckSingle?.launch(mediaProjectionManager.createScreenCaptureIntent())
            }
        } else {
            permissionCheckMultiple?.launch(list)
        }
    }

    private fun areAllPermissionsGranted(fragment: Fragment): Boolean =
        requiredPermissions.all {
            if (it == PermissionType.MediaProjection) {
                return@all false
            } else {
                it.isGranted(fragment)
            }
        }

    private fun getPermissionList() =
        requiredPermissions.flatMap { it.permissions.toList() }.toTypedArray()

    private fun PermissionType.isGranted(fragment: Fragment): Boolean {
        return permissions.all {
            hasPermission(fragment, it)
        }
    }

    private fun shouldShowPermissionRationale(fragment: Fragment) =
        requiredPermissions.any {
            it.requiresRationale(fragment)
        }

    private fun PermissionType.requiresRationale(fragment: Fragment): Boolean =
        permissions.any { fragment.shouldShowRequestPermissionRationale(it) }

    private fun hasPermission(fragment: Fragment, permission: String): Boolean =
        ContextCompat.checkSelfPermission(
            fragment.requireContext(),
            permission
        ) == PackageManager.PERMISSION_GRANTED

    companion object {
        fun from(fragment: Fragment) = PermissionManager(WeakReference(fragment))
    }
}