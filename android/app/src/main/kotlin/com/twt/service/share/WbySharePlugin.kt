package com.twt.service.share

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import com.tencent.connect.common.Constants
import com.tencent.tauth.DefaultUiListener
import com.tencent.tauth.Tencent
import com.tencent.tauth.UiError
import com.twt.service.common.LogUtil
import com.twt.service.common.WbyPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class WbySharePlugin : WbyPlugin(), ActivityAware, PluginRegistry.RequestPermissionsResultListener,
    PluginRegistry.ActivityResultListener {
    private lateinit var activityBinding: ActivityPluginBinding
    private lateinit var result: MethodChannel.Result
    private var continueDo: (() -> Unit)? = null

    private val mTencent: Tencent? by lazy {
        Tencent.createInstance(
            APP_ID,
            context,
            APP_AUTHORITIES
        )
    }

    override val name: String
        get() = "com.twt.service/share"

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
            "shareImgToQQ" -> kotlin.runCatching {
                if (mTencent == null) {
                    result.error("", "QQ分享配置错误", null)
                    return
                }
                continueDo = {
                    Tencent.setIsPermissionGranted(true)
                    activityBinding.addActivityResultListener(this)
                    QQFactory(mTencent!!, activityBinding.activity, qqShareListener).shareImg(
                        call
                    )
                }
                this.result = result
                if (!requestPermissions()) {
                    continueDo!!.invoke()
                }
            }.onFailure {
                result.error("-1", "cannot share img to qq", "$it")
            }
            else -> result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
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

        // TODO: 源码里 onRequestPermissionsResult 和 onActivityResult 略有差别
//        activityBinding.removeRequestPermissionsResultListener(this)

        if (permissions == null || grantResults == null || continueDo == null) {
            result.error("", "permissions and grantResults both null", null)
            return true
        }

        for (i in grantResults.indices) {
            if (grantResults[i] == PackageManager.PERMISSION_GRANTED) {
                mPermissions.remove(permissions[i])
            }
        }

        if (mPermissions.isEmpty()) {
            continueDo?.invoke()
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
            activityBinding.addRequestPermissionsResultListener(this)
            ActivityCompat.requestPermissions(
                activityBinding.activity,
                mPermissions.toTypedArray(),
                REQUEST_CODE
            )
        }
        return mPermissions.isNotEmpty()
    }

    private val mPermissions = mutableListOf<String>()

    private val qqShareListener = object : DefaultUiListener() {
        override fun onComplete(obj: Any?) {
            log("success : $obj")
            result.success("")
        }

        override fun onError(error: UiError?) {
            log("error : $error")
            result.error("", "qq share error", "$error")
        }

        override fun onCancel() {
            log("cancel")
            result.success("cancel")
        }

        override fun onWarning(code: Int) {
            log("warning: $code")
            result.success("warning : $code")
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == Constants.REQUEST_QQ_SHARE) {
            Tencent.onActivityResultData(requestCode, resultCode, data, qqShareListener)
            activityBinding.removeActivityResultListener(this)
            return true
        }
        return false
    }

    companion object {
        const val APP_ID = "1104743406"
        const val APP_AUTHORITIES = "com.twt.service.qqprovider"
        const val TAG = "WBY_SHARE"
        const val REQUEST_CODE = 10086
        val PERMISSIONS =
            listOf(Manifest.permission.READ_PHONE_STATE, Manifest.permission.WRITE_EXTERNAL_STORAGE)

        fun log(message: String) = LogUtil.d(TAG, message)
    }
}