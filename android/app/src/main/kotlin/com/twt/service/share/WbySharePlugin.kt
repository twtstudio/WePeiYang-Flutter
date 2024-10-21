package com.twt.service.share

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import com.twt.service.common.LogUtil
import com.twt.service.common.WbyPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class WbySharePlugin : WbyPlugin(), ActivityAware, PluginRegistry.ActivityResultListener {
    internal lateinit var activityBinding: ActivityPluginBinding
    private val permissionListener by lazy { SharePermissionResultListener(this) }
    internal lateinit var result: MethodChannel.Result
    internal var continueDo: (() -> Unit)? = null


    override val name: String
        get() = "com.twt.service/share"

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            else -> result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        activityBinding.addRequestPermissionsResultListener(permissionListener)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        activityBinding.removeRequestPermissionsResultListener(permissionListener)
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        return false
    }

    companion object {
        const val TAG = "SHARE"
        fun log(message: String) = LogUtil.d(TAG, message)
    }
}

internal class SharePermissionResultListener(val plugin: WbySharePlugin) :
    PluginRegistry.RequestPermissionsResultListener {
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        if (REQUEST_CODE != requestCode) {
            return false
        }

        if (plugin.continueDo == null) {
            plugin.result.error("", "permissions and grantResults both null", null)
            return true
        }

        for (i in grantResults.indices) {
            if (grantResults[i] == PackageManager.PERMISSION_GRANTED) {
                mPermissions.remove(permissions[i])
            }
        }

        if (mPermissions.isEmpty()) {
            plugin.continueDo?.invoke()
        }

        return true
    }

    internal fun requestPermissions(): Boolean {
        mPermissions.clear()
        val permissions =
            listOf(Manifest.permission.READ_PHONE_STATE, Manifest.permission.WRITE_EXTERNAL_STORAGE)
        for (permission in permissions) {
            if (ActivityCompat.checkSelfPermission(
                    plugin.activityBinding.activity,
                    permission
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                mPermissions.add(permission)
            }
        }
        WbySharePlugin.log("need permissions: $mPermissions")
        if (mPermissions.size > 0) {
            ActivityCompat.requestPermissions(
                plugin.activityBinding.activity,
                mPermissions.toTypedArray(),
                REQUEST_CODE
            )
        }
        return mPermissions.isNotEmpty()
    }

    private val mPermissions = mutableListOf<String>()

    companion object {
        const val REQUEST_CODE = 10086
    }
}