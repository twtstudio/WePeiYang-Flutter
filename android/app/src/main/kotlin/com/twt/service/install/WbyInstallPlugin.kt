package com.twt.service.install


import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.Settings
import android.widget.Toast
import androidx.core.content.FileProvider
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
        when (call.method) {
            "install" -> {
                val apkName = call.argument<String>("apkName")
                if (apkName == null) {
                    result.error(NO_PATH_ERROR, "no path", "")
                } else {
                    methodCall = result
                    installAPK(apkName)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun installAPK(apkName: String) {
        try {
            val dir = context.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS)
                ?: throw Exception("can't find download dir")
            resultFile = File(dir.path + File.separator + "apk" + File.separator + apkName)
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
                "com.twt.service.apkprovider",
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
        const val TAG = "WBY_INSTALL"
        const val REQUEST_PERMISSION = 101
        const val INSTALL_APK = 202
        const val NO_PERMISSION = ""
        const val INSTALL_APK_ERROR = ""
        const val NO_PATH_ERROR = ""
    }
}