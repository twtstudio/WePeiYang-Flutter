package com.twt.service.share

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.util.Log
import androidx.core.app.ActivityCompat
import com.tencent.tauth.Tencent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class WbySharePlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware,
    PluginRegistry.RequestPermissionsResultListener {
    private lateinit var shareChannel: MethodChannel
    private lateinit var context: Context
    private lateinit var activityBinding: ActivityPluginBinding
    private var continueToDo: (() -> Unit)? = null

    private val mTencent: Tencent by lazy {
        Tencent.createInstance(
            APP_ID,
            context,
            APP_AUTHORITIES
        )
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        shareChannel = MethodChannel(binding.binaryMessenger, "com.twt.service/share")
        shareChannel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        shareChannel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "shareToQQ" -> {
                try {
//                    QQFactory(mTencent, activityBinding.activity).share(call)
                    result.success("success")
                } catch (e: Exception) {
                    result.error("-1", "cannot share to qq", null)
                }
            }
            "shareImgToQQ" -> {
                try {
                    continueToDo = {
                        Tencent.setIsPermissionGranted(true)
                        QQFactory(mTencent, activityBinding.activity).shareImg(call)
                    }

                    if (!requestPermissions()) {
                        continueToDo?.invoke()
                    }
//                    result.success("success")
                } catch (e: Exception) {
                    throw e
//                    result.error("-1", "cannot share img to qq", "$e")
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding

        CoroutineScope(Dispatchers.Main).launch {
            delay(5000)
            requestPermissions()
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        //
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        //
    }

    override fun onDetachedFromActivity() {
        //
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>?,
        grantResults: IntArray?
    ): Boolean {
        if (REQUEST_CODE != requestCode) {
            return false
        }

        activityBinding.removeRequestPermissionsResultListener(this)

        if (permissions == null || grantResults == null) {
            continueToDo = null
            return true
        }

        for (i in grantResults.indices) {
            if (grantResults[i] == PackageManager.PERMISSION_GRANTED) {
                mPermissions.remove(permissions[i])
            }
        }

        if (mPermissions.isEmpty()) {
            continueToDo?.invoke()
            continueToDo = null
        }

        return true
    }

    private fun requestPermissions(): Boolean {
        mPermissions.clear()
        for (permission in PERMISSIONS) {
            if (ActivityCompat.checkSelfPermission(
                    activityBinding.activity,
                    permission
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                mPermissions.add(permission)
            }
        }
        log("need permissions: $mPermissions")
        activityBinding.addRequestPermissionsResultListener(this)
        if (mPermissions.size > 0) {
            ActivityCompat.requestPermissions(
                activityBinding.activity,
                mPermissions.toTypedArray(),
                REQUEST_CODE
            )
        }
        return mPermissions.isNotEmpty()
    }

    private val mPermissions = mutableListOf<String>()

    companion object {
        const val APP_ID = "1104743406"
        const val APP_AUTHORITIES = "com.twt.service.qqprovider"
        const val TAG = "WBY_SHARE"
        const val REQUEST_CODE = 10086
        val PERMISSIONS =
            listOf(Manifest.permission.READ_PHONE_STATE, Manifest.permission.WRITE_EXTERNAL_STORAGE)

        fun log(msg: String) = Log.d(TAG, msg)
    }
}