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

class WbyFixPlugin : WbyPlugin() {
    override val name: String
        get() = "com.twt.service/hot_fix"

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "hotFix" -> hotFix(call, result)
                "restartApp" -> restartApp(result)
                else -> result.notImplemented()
            }
        } catch (e: Throwable) {
            LogUtil.e(TAG, e)
            result.error("", e.message, "")
        }
    }

    private fun hotFix(call: MethodCall, result: MethodChannel.Result) {
        // 下载的.so文件路径，按道理说应该为  ···/Download/so/90-3-libapp.so
        // 下面将文件转移到应用私有目录下的hotfix文件夹 data/data/com.twt.service/files/hotfix/
        val path = call.argument<String>("path")
        if (path == null) {
            log("NO_PATH_ERROR")
            result.error("NO_PATH_ERROR", "don't find path : $path", "")
        } else {
            // 下载的是 zip 文件
            val download = File(path)
            if (!download.exists()) {
                log("DOWNLOAD_FILE_NOT_FOUND : $path")
                result.error("DOWNLOAD_FILE_NOT_FOUND", "no download file : $path", "")
                return
            }
            if (download.extension != "zip") {
                log("DOWNLOAD_FILE_TYPE_ERROR : $path")
                result.error("DOWNLOAD_FILE_TYPE_ERROR", "download file not zip : $path", "")
                return
            }

            // 版本更新有两种方式：
            // 1. 使用apk
            // 2. 更新libapp.so
            // 使用第二种方式为下载zip文件后解压缩得到so文件
            // zip文件的名字为 eg: 96-92-libapp.zip  96: 最新版本号 92: 从哪个版本开始可以使用热更新

            // TODO: 应该在下载之前就校验
//            if (WbySharePreference.soFileContainAndCanUse(download.absolutePath)) {
//                log("already download hot fix .so file : ${download.absolutePath}")
//                result.success(download.parent)
//                return
//            }

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