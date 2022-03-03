package com.twt.service

import android.util.Log
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
import com.twt.service.widget.WbyWidgetPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterShellArgs

class MainActivity : FlutterActivity() {

    // 加入微北洋使用的所有自己写的 plugin
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(
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
                WbyFixPlugin()
            )
        )
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

    companion object {
        const val TAG = "WBY_MainActivity"
        fun log(message: String) = LogUtil.d(TAG, message)
    }
}