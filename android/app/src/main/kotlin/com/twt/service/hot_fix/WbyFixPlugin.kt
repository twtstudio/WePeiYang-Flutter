package com.twt.service.hot_fix

import android.content.Context
import android.content.Intent
import android.util.Log
import com.twt.service.BuildConfig
import com.twt.service.common.WbySharePreference
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream

// 微北洋热更新流程：
// 即为localVersionCode + webFixCode = remoteVersionCode的情况，证明可以通过热更新或下载apk更新应用
// 1. 默认为用户下载libapp.so文件，加载好后弹出dialog告诉用户更新了啥，是否立刻重启获得新版本，完毕
// 2. 如果用户之后打开应用发生闪退，则标记这个文件不可使用，下次打开应用加载上一次的libapp.so文件，检查更新，通过apk下载更新

// 注： hotfix的更新方式为改变微北洋启动路径，在应用私有文件夹下创建hotfix文件夹，将热修复的.so文件存储在那里，然后向
//     WbySharePreference.fixSo中添加新获得的.so文件路径，存储方式为获取的所有.so文件列表（当前版本，在应用更新后，
//     不符合当前版本的.so文件将被清除）。如果启动应用发生闪退，则猜测获得的热修复.so文件出现问题，在下次启动时将跳过该文件，
//     加载上次成功启动的文件并检查更新
// 注：下载.so文件的方式为：WbyDownloadPlugin
//
// webFixCode(更新的接口中) remoteVersionCode(新的apk版本)
// 如果 webFixCode = 0 ：则表示新版的apk进行了安卓端的改动，需要重新下载安装apk
// localVersionCode(现在的apk版本)
// 如果localVersionCode + webFixCode >= remoteVersionCode && (localVersionCode < remoteVersionCode) 则代表可以通过热修复更新 也可以通过下载新的安装包更新
// 如果localVersionCode + webFixCode < remoteVersionCode 则表示要不就是忘改了，要不就是对安卓端进行了修改，这时候只能通过下载新的安装包更新
// 如果localVersionCode > remoteVersionCode 这就必定有问题，要不是写错了，要不是开发人员
// 所以本地没必要存fixCode，只用在更新的接口中告诉是否能通过替换libapp.so文件进行更新

class WbyFixPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "com.twt.service/hot_fix")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "hotFix" -> {
                // 下载的.so文件路径，按道理说应该为  ···/Download/so/90-3-libapp.so
                // 下面将文件转移到应用私有目录下的hotfix文件夹 data/data/com.twt.service/files/hotfix/
                val path = call.argument<String>("path")
                if (path == null) {
                    log(NO_PATH_ERROR)
                    result.error(NO_PATH_ERROR, "don't find path : $path", "")
                } else {
                    moveSoFile(result, path)
                }
            }
            "restartApp" -> {
                runCatching {
                    // https://github.com/gabrimatic/restart_app/blob/master/android/src/main/kotlin/gabrimatic/info/restart/RestartPlugin.kt
                    context.startActivity(
                        Intent.makeRestartActivityTask(
                            (context.packageManager.getLaunchIntentForPackage(
                                context.packageName
                            ))!!.component
                        )
                    )
                    Runtime.getRuntime().exit(0)
                }.onFailure {
                    result.error("","","")
                }.onSuccess {
                    // 如果success，那么当然就重启应用了
                    result.success("")
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun moveSoFile(result: MethodChannel.Result, path: String) {
        val download = File(path)
        if (!download.exists()) {
            log("DOWNLOAD_FILE_NOT_FOUND : $path")
            result.error(DOWNLOAD_FILE_NOT_FOUND, "no download file : $path", "")
            return
        }
        val nameSplit = download.name.split("-")
        if (nameSplit.size < 3 || nameSplit[0] != BuildConfig.VERSION_CODE.toString() || !nameSplit.last()
                .endsWith(".so")
        ) {
            log("DOWNLOAD_FILE_NOT_ALLOW : ${download.name}")
            result.error(DOWNLOAD_FILE_NOT_ALLOW, "", "")
            return
        }

        if (WbySharePreference.soFileContainAndCanUse(download.absolutePath)) {
            log("already download hot fix .so file : ${download.absolutePath}")
            result.success(download.parent)
            return
        }

        val fixDir = File(context.filesDir,"hotfix")
        if (!fixDir.exists()){
            fixDir.mkdir()
        }

        val fix = File(fixDir, download.name)

        fix.runCatching {
            // 如果不存在，就移动文件到这里
            if (!exists()){
                FileInputStream(download).use { input ->
                    FileOutputStream(absolutePath).use { output ->
                        input.copyTo(output)
                        output.flush()
                    }
                }
                WbySharePreference.fixSo = absolutePath
            }
            absolutePath
        }.onSuccess {
            download.deleteOnExit()
            log("move so file success : $it")
            result.success(it)
        }.onFailure {
            log("move so file failure : $it")
            result.error(COPY_FILE_ERROR, it.message, "")
        }
    }

    companion object {
        const val TAG = "WBY_HOT_FIX"
        const val DOWNLOAD_FILE_NOT_FOUND = "DOWNLOAD_FILE_NOT_FOUND"
        const val COPY_FILE_ERROR = "COPY_FILE_ERROR"
        const val NO_PATH_ERROR = "NO_PATH_ERROR"
        const val DOWNLOAD_FILE_NOT_ALLOW = "DOWNLOAD_FILE_NOT_ALLOW"
        fun log(message: String) = Log.d(TAG, message)
    }
}