package com.twt.service.install


import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.widget.Toast
import androidx.core.content.FileProvider
import com.twt.service.common.LogUtil
import com.twt.service.common.WbyPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.io.File

class WbyInstallPlugin : WbyPlugin(), ActivityAware, PluginRegistry.ActivityResultListener {

    override val name: String
        get() = "com.twt.service/install"

    private lateinit var activityBinding: ActivityPluginBinding
    private lateinit var resultFile: File
    private lateinit var methodCall: MethodChannel.Result

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        LogUtil.d(TAG, "onMethodCall + ${call.method}")

        kotlin.runCatching {
            when (call.method) {
                "install" -> {
                    val path = call.argument<String>("path")!!
                    methodCall = result
                    installAPK(path)
                }
                "goToMarket" -> goToMarket(result)
                "canGoToMarket" -> canGoToMarket(result)
                else -> result.notImplemented()
            }
        }.onFailure {
            LogUtil.e(TAG, it)
            result.error("", "$it", "")
        }
    }

    private fun canGoToMarket(result: MethodChannel.Result) {
        if (marketIntent.resolveActivity(context.packageManager) != null) {
            result.success(true)
        } else {
            result.success(false)
        }
    }

    /**
     * 跳转到应用市场的intent
     */
    private val marketIntent
        get() = Intent(Intent.ACTION_VIEW).apply {
            // 现在只上架了 HUAWEI,XIAOMI,OPPO,VIVO
            `package` = when (Build.BRAND.lowercase()) {
                "huawei", "honor" -> "com.huawei.appmarket"
                "xiaomi" -> "com.xiaomi.market"
                "oppo" -> "com.oppo.market"
                "vivo" -> "com.bbk.appstore"
                else -> null
            }
            // 去掉后缀
            val packageName = context.packageName.split(".").subList(0, 3).joinToString(".")
            data = Uri.parse("market://details?id=$packageName")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }

    private fun goToMarket(result: MethodChannel.Result) {
        context.startActivity(marketIntent)
        result.success(true)
    }

    private fun installAPK(path: String) {
        try {
            resultFile = File(path)
            activityBinding.addActivityResultListener(this)
            installApkWithSdkVersion()
        } catch (e: Exception) {
            methodCall.error(INSTALL_APK_ERROR, "install apk error", e.message)
        }
    }

    private fun installApkWithSdkVersion() {
        // version < N 时 直接通过 intent 安装
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            // N == version 或 canRequestPackageInstalls 直接安装
            // 因为 Android O(8) 之后安装未知来源应用需要申请权限
            // Android N(7) 之后需要 FileProvider
            if (canRequestPackageInstalls) {
                activityBinding.activity.startActivityForResult(intentAfterN, INSTALL_APK)
            } else {
                // version >= O(8) 且 需要请求权限
                val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES).apply {
                    data = Uri.parse("package:" + context.packageName)
                }
                activityBinding.activity.startActivityForResult(intent, REQUEST_PERMISSION)
            }
        } else {
            activityBinding.activity.startActivityForResult(intentBeforeN, INSTALL_APK)
        }
    }

    private val intentBeforeN: Intent
        get() = Intent(Intent.ACTION_VIEW).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            val uri = Uri.fromFile(resultFile)
            setDataAndType(uri, "application/vnd.android.package-archive")
        }

    private val intentAfterN: Intent
        get() = Intent(Intent.ACTION_VIEW).apply {
            //参数1 上下文, 参数2 Provider主机地址 和配置文件中保持一致   参数3  共享的文件
            val apkUri = FileProvider.getUriForFile(
                context,
                "${context.packageName}.ApkProvider",
                resultFile,
            )
            //添加这一句表示对目标应用临时授权该Uri所代表的文件
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            setDataAndType(apkUri, "application/vnd.android.package-archive")
        }

    private val canRequestPackageInstalls: Boolean
        get() = Build.VERSION.SDK_INT < Build.VERSION_CODES.O ||
                context.packageManager.canRequestPackageInstalls()

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        LogUtil.d(TAG, "onAttachedToActivity")
    }

    override fun onDetachedFromActivityForConfigChanges() {
        LogUtil.d(TAG, "onDetachedFromActivityForConfigChanges")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        LogUtil.d(TAG, "onReattachedToActivityForConfigChanges")
    }

    override fun onDetachedFromActivity() {
        LogUtil.d(TAG, "onDetachedFromActivity")

    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        // 请求安装apk权限的回调
        if (requestCode == REQUEST_PERMISSION) {
            // 当过了请求权限的页面后就取消监听，不然会出问题
            activityBinding.removeActivityResultListener(this)
            if (resultCode == Activity.RESULT_OK) {
                // 主要是因为安装apk的result很神奇~~~ 所以只好把listener去掉
                activityBinding.activity.startActivityForResult(intentAfterN, INSTALL_APK)
            } else if (resultCode == Activity.RESULT_CANCELED) {
                Toast.makeText(context, "请允许安装第三方应用权限", Toast.LENGTH_LONG).show()
                methodCall.error(NO_PERMISSION, "don't allow permission", "")
            }
            return true
        }
        return false
    }

    companion object {
        const val TAG = "INSTALL"
        const val REQUEST_PERMISSION = 101
        const val INSTALL_APK = 202
        const val NO_PERMISSION = ""
        const val INSTALL_APK_ERROR = ""
        const val NO_PATH_ERROR = ""
    }
}