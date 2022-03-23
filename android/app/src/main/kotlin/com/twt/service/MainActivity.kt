package com.twt.service

import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PersistableBundle
import android.view.Surface
import android.view.SurfaceControl
import androidx.core.content.FileProvider
import androidx.lifecycle.lifecycleScope
import com.twt.service.cloud_config.WbyCloudConfigPlugin
import com.twt.service.common.ChangeDisplay
import com.twt.service.common.LogUtil
import com.twt.service.common.WbySharePreference
import com.twt.service.download.WbyDownloadPlugin
import com.twt.service.hot_fix.WbyFixPlugin
import com.twt.service.image.WbyImageSavePlugin
import com.twt.service.install.WbyInstallPlugin
import com.twt.service.location.WbyLocationPlugin
import com.twt.service.message.WbyMessagePlugin
import com.twt.service.push.WbyPushPlugin
import com.twt.service.share.WbySharePlugin
import com.twt.service.statistics.WbyStatisticsPlugin
import com.twt.service.widget.WbyWidgetPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterShellArgs
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.io.File

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
        super.onCreate(savedInstanceState, persistentState)

        // 高刷新率
        // https://juejin.cn/post/6844904163579527181
        // https://juejin.cn/post/6844904195909222414
        // https://developer.android.com/guide/topics/media/frame-rate
        // https://pub.dev/packages/flutter_displaymode
    }

    // 加入微北洋使用的所有自己写的 plugin
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.runCatching {
            add(
                setOf(
                    // 课程表小组件
                    WbyWidgetPlugin(),
                    // 点击通知，等应用进入主页面后，从 eventList 中获取事件
                    WbyMessagePlugin(),
                    // qq分享（图片，文字），微信分享（还没做）
                    WbySharePlugin(),
                    // 微北洋通用下载工具
                    WbyDownloadPlugin(),
                    // 应用内更新 apk 安装
                    WbyInstallPlugin(),
                    // 高德地图 api 获取定位（疫情填报）
                    WbyLocationPlugin(),
                    // 保存图片
                    WbyImageSavePlugin(),
                    // 个推推送
                    WbyPushPlugin(),
                    // 添加热修复文件
                    WbyFixPlugin(),
                    // 友盟统计
                    WbyStatisticsPlugin(),
                    // 友盟云参数
                    WbyCloudConfigPlugin(),
                )
            )
        }
    }

    // https://blog.csdn.net/llew2011/article/details/105453204/
    // dart_snapshot.cc的SearchMapping()方法内部循环遍历native_library_path查找libapp.so，
    // 如果找到就返回，最终到不到就返回一个nullptr。我们知道native_library_path就是解析从Java层传
    // 递过来的配置参数列表shellArgs中的key是aot-shared-library-name对应的值，
    // 热更新优雅的实现方式，very nice！
    override fun getFlutterShellArgs(): FlutterShellArgs {
        val shellArgs = super.getFlutterShellArgs()
        takeIf { !BuildConfig.DEBUG }?.let {
            WbyFixPlugin.log("getFlutterShellArgs")
            WbySharePreference.fixSo?.let {
                WbyFixPlugin.log("load .so file : $it")
                shellArgs.add("--aot-shared-library-name=$it")
            }
        }
        return shellArgs
    }

    // TODO: 2022/1/19 等待高人把这些代码移到 plugin 里面去，至少现在还不行
    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        takeIf { hasFocus && (flutterEngine != null) }?.runCatching {
            (flutterEngine!!.plugins.get(WbyPushPlugin::class.java) as? WbyPushPlugin)
                ?.onWindowFocusChanged()
        }
        log("onWindowFocusChanged : $hasFocus")
    }

    override fun onFlutterUiDisplayed() {
        super.onFlutterUiDisplayed()
        WbySharePreference.setCurrentUseSoFileCanUse()
    }

    // 禁用显示大小改变和文字大小改变
    override fun attachBaseContext(newBase: Context) {
        ChangeDisplay.changeConfig(newBase)
        super.attachBaseContext(newBase)
    }

    // 更改字体或显示大小后，自动重启activity（参考了高德地图）
    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        ChangeDisplay.recreateWhenConfigChange(newConfig, this)
    }

    fun startMarket() {
        // https://blog.csdn.net/weixin_36318548/article/details/117544612

        val intent = Intent(Intent.ACTION_VIEW)

        // 如果不指定具体的报名，则系统弹出弹窗询问用哪个打开
//        intent.`package` = when (Build.BRAND.lowercase()) {
//            "huawei" -> "com.huawei.appmarket"
//            "honor" -> ""
//            "xiaomi" -> "com.xiaomi.market"
//            "oppo" -> "com.oppo.market"
//            else -> ""
//        }
        intent.data = Uri.parse("market://details?id=${applicationContext.packageName}")
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        applicationContext.startActivity(intent)
    }

    fun shareText() {
        val intent = Intent().apply {
            action = Intent.ACTION_SEND
            type = "text/plain"
            putExtra(Intent.EXTRA_TEXT, "文本内容")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            `package` = "com.tencent.mm"
        }
        try {
            LogUtil.d(TAG, "share")
            applicationContext.startActivity(intent)
        } catch (e: Throwable) {
            LogUtil.e(TAG, e)
        }
    }

    fun shareImages(images: List<File>) {
        // 跳转到相册
        // https://blog.csdn.net/weixin_39524882/article/details/117613777

        // 将图片分享到app
        // https://blog.csdn.net/qq_34983989/article/details/78438254

        // 系统分享
        // https://www.cnblogs.com/yongdaimi/p/10287477.html
        // https://juejin.cn/post/6844903439193899022
        // https://juejin.cn/post/6949123159392157732?share_token=a6e39a23-15a7-4e40-aab7-dbbbac244e96
        // https://juejin.cn/post/6980664932974985247

        // 存储图片到相册
        // https://juejin.cn/post/7042218651482587172

        // 图片裁剪
        // https://juejin.cn/post/6922022765537001485

        val imageUris = images.mapNotNull {
            FileProvider.getUriForFile(context, "$packageName.share.QQProvider", it)
        }

        val shareIntent = Intent().apply {
            action = Intent.ACTION_SEND_MULTIPLE
            type = "image/*"
            putExtra(Intent.EXTRA_STREAM, imageUris.toTypedArray())
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }

        // https://blog.csdn.net/qq_32534441/article/details/105861078
        startActivity(Intent.createChooser(shareIntent, "dlgTitle"))
    }

    fun shareImage(image: File) {
        val uri = FileProvider.getUriForFile(context, "$packageName.share.QQProvider", image)

        val intent = Intent().apply {
            action = Intent.ACTION_SEND
            type = "image/*"
            putExtra(Intent.EXTRA_STREAM, uri)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(Intent.createChooser(intent, "title"))
    }

    companion object {
        const val TAG = "WBY_MainActivity"
        fun log(message: String) = LogUtil.d(TAG, message)
    }
}