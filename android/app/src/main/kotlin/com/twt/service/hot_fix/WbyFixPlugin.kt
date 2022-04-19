package com.twt.service.hot_fix

import android.content.Intent
import com.twt.service.common.FileUtil
import com.twt.service.common.LogUtil
import com.twt.service.common.WbyPlugin
import com.umeng.analytics.MobclickAgent
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.zip.ZipFile

/**
 * 微北洋热修复加载
 */
class WbyFixPlugin : WbyPlugin() {
    override val name: String
        get() = "com.twt.service/hot_fix"

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "hotFix" -> hotFix(call, result)
                "restartApp" -> restartApp(result)
                "soFileCanUse" -> soFileCanUse(call, result)
                else -> result.notImplemented()
            }
        } catch (e: Throwable) {
            LogUtil.e(TAG, e)
            result.error("", e.message, "")
        }
    }

    private fun soFileCanUse(call: MethodCall, result: MethodChannel.Result) {
        val fileName = call.argument<String>("name")!!
        result.success(HotFixPreference.soFileContainAndCanUse(fileName))
    }

    private fun hotFix(call: MethodCall, result: MethodChannel.Result) {
        // 下载的.so文件路径，按道理说应该为  ···/Download/so/90-libapp.so
        // 下面将文件转移到应用私有目录下的hotfix文件夹 data/data/com.twt.service/files/hotfix/
        val path = call.argument<String>("path")
        if (path == null) {
            log("NO_PATH_ERROR")
            result.error("NO_PATH_ERROR", "don't find path : $path", "")
        } else {
            // 下载的是 zip 文件
            val download = File(path)
            if (!download.exists() || download.extension != "zip") {
                log("DOWNLOAD_FILE_ERROR : $path")
                result.error("DOWNLOAD_FILE_ERROR", "download file error: $path", "")
                return
            }

            val fixDir = FileUtil.fixDirectory(context)

            val fix = File(fixDir, download.nameWithoutExtension + ".so")
            fix.runCatching {
                // 如果存在就删除
                if (exists()) delete()
                ZipFile(download).use { zip ->
                    val entry = zip.entries().asSequence().first()
                    zip.getInputStream(entry).use { input ->
                        val output = outputStream()
                        input.copyTo(output)
                        output.close()
                    }
                }
                HotFixPreference.checkAndSetFixSo(nameWithoutExtension)
                absolutePath
            }.onSuccess {
                download.delete()
                log("move so file success : $it")
                result.success(it)
            }.onFailure {
                fix.delete()
                LogUtil.e(TAG, it)
                result.error("COPY_FILE_ERROR", it.message, "")
            }
        }
    }

    /**
     * 重启微北洋，实际上是重启 MainActivity
     */
    private fun restartApp(result: MethodChannel.Result) {
        runCatching {
            MobclickAgent.onKillProcess(context)
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
            result.error("", "", "")
        }.onSuccess {
            // 如果success，那么当然就重启应用了
            result.success("")
        }
    }

    companion object {
        const val TAG = "HOT_FIX"
        fun log(message: String) = LogUtil.d(TAG, message)
    }
}