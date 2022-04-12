package com.twt.service.share

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import com.tencent.connect.common.Constants
import com.tencent.tauth.Tencent
import com.twt.service.common.LogUtil
import com.twt.service.common.WbyPlugin
import com.twt.service.share.qq.QQFactory
import com.twt.service.share.qq.QQListener
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

    private val mTencent: Tencent? by lazy {
        Tencent.createInstance(
            "1104743406",
            context,
            "${context.packageName}.ImageProvider"
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
                if (!permissionListener.requestPermissions()) {
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

    private val qqShareListener by lazy { QQListener(this) }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == Constants.REQUEST_QQ_SHARE) {
            Tencent.onActivityResultData(requestCode, resultCode, data, qqShareListener)
            activityBinding.removeActivityResultListener(this)
            return true
        }
        return false
    }

    companion object {
        const val TAG = "WBY_SHARE"
        fun log(message: String) = LogUtil.d(TAG, message)
    }
}

internal class SharePermissionResultListener(val plugin: WbySharePlugin) :
    PluginRegistry.RequestPermissionsResultListener {
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>?,
        grantResults: IntArray?
    ): Boolean {
        if (REQUEST_CODE != requestCode) {
            return false
        }

        if (permissions == null || grantResults == null || plugin.continueDo == null) {
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

    internal val mPermissions = mutableListOf<String>()

    companion object {
        const val REQUEST_CODE = 10086
    }
}