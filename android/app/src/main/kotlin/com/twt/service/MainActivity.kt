package com.twt.service

import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.widget.Toast
import com.twt.service.cloud_config.WbyCloudConfigPlugin
import com.twt.service.common.ChangeDisplay
import com.twt.service.common.LogUtil
import com.twt.service.device_info.WbyDeviceInfoPlugin
import com.twt.service.download.WbyDownloadPlugin
import com.twt.service.hot_fix.HotFixPreference
import com.twt.service.hot_fix.WbyFixPlugin
import com.twt.service.image.WbyImageSavePlugin
import com.twt.service.install.WbyInstallPlugin
import com.twt.service.local_setting.WbyLocalSettingPlugin
import com.twt.service.location.WbyLocationPlugin
import com.twt.service.message.EventDispatcher
import com.twt.service.message.WbyMessagePlugin
import com.twt.service.push.WbyPushPlugin
import com.twt.service.share.WbySharePlugin
import com.twt.service.statistics.WbyStatisticsPlugin
import com.twt.service.widget.WbyWidgetPlugin
import io.flutter.embedding.engine.FlutterShellArgs
import android.os.Build
import android.os.Bundle
import android.net.Uri
import androidx.core.view.WindowCompat
import androidx.core.content.pm.ShortcutInfoCompat
import androidx.core.content.pm.ShortcutManagerCompat
import androidx.core.graphics.drawable.IconCompat
import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {

    companion object {
        const val TAG = "MainActivity"
        private const val CHANNEL = "icon_switch"
        fun log(message: String) = LogUtil.d(TAG, message)
    }

    private val iconAliases = listOf(
        "com.twt.service.ICONBlue",
        "com.twt.service.ICONCyan",
        "com.twt.service.ICONGold",
        "com.twt.service.ICONPink",
        "com.twt.service.ICONPurple",
        "com.twt.service.ICONRed",
        "com.twt.service.ICONYellow",
        "com.twt.service.ICONSpring",
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        // Aligns the Flutter view vertically with the window.
        WindowCompat.setDecorFitsSystemWindows(getWindow(), false)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Disable the Android splash screen fade out animation to avoid
            // a flicker before the similar frame is drawn in Flutter.
            splashScreen.setOnExitAnimationListener { splashScreenView -> splashScreenView.remove() }
        }

        log("onCreate action=${intent?.action} data=${intent?.dataString} component=${intent?.component}")
        EventDispatcher.enqueueShortcutIntent(intent)
        super.onCreate(savedInstanceState)

        publishLauncherShortcuts()
//        enableLauncherForDebug()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        log("onNewIntent action=${intent.action} data=${intent.dataString} component=${intent.component}")
        EventDispatcher.enqueueShortcutIntent(intent)
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
                    // 本地设置
                    WbyLocalSettingPlugin(),
                    // 设备信息调试
                    WbyDeviceInfoPlugin(),
                )
            )
        }.onFailure {
            Toast.makeText(this, "不该出现的错误：$it", Toast.LENGTH_LONG).show()
            LogUtil.e(TAG, it)
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "switchIcon" -> {
                        val target = call.argument<String>("target")!!
                        switchIcon(target)
                        result.success(null)
                    }

                    "getCurrentIcon" -> result.success(getCurrentIcon())

                    "restartApp" -> restartApp(result)

                    else -> result.notImplemented()
                }
            }

    }

//    private fun enableLauncherForDebug() {
//        if (BuildConfig.DEBUG) {
//            // 调试模式下 MainActivity 保持 Launcher
//            packageManager.setComponentEnabledSetting(
//                ComponentName(this, "com.twt.service.MainActivity"),
//                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
//                PackageManager.DONT_KILL_APP
//            )
//        } else {
//            // Release 时禁用 MainActivity Launcher
//            packageManager.setComponentEnabledSetting(
//                ComponentName(this, "com.twt.service.MainActivity"),
//                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
//                PackageManager.DONT_KILL_APP
//            )
//        }
//    }

    //应用图标切换
    private fun switchIcon(target: String) {
        val pm = packageManager

        // 禁用 MainActivity launcher
        pm.setComponentEnabledSetting(
            ComponentName(this, "com.twt.service.MainActivity"),
            PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
            PackageManager.DONT_KILL_APP
        )

        iconAliases.forEach { alias ->
            val state = if (alias == target)
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            else
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED

            pm.setComponentEnabledSetting(
                ComponentName(this, alias),
                state,
                PackageManager.DONT_KILL_APP
            )
        }
    }

    private fun getCurrentIcon(): String {
        val pm = packageManager
        return iconAliases.firstOrNull { alias ->
            pm.getComponentEnabledSetting(ComponentName(this, alias)) ==
                    PackageManager.COMPONENT_ENABLED_STATE_ENABLED
        } ?: "com.twt.service.ICONBlue"
    }

    private fun publishLauncherShortcuts() {
        val launcherComponent = getCurrentLauncherComponent()
        val shortcuts = listOf(
            ShortcutInfoCompat.Builder(this, "shortcut_schedule")
                .setShortLabel("课程表")
                .setLongLabel("课程表")
                .setIcon(IconCompat.createWithResource(this, R.drawable.schedule))
                .setIntent(
                    Intent().apply {
                        component = launcherComponent
                        action = Intent.ACTION_VIEW
                        data = Uri.parse("wpy://wpy.app/schedule")
                    }
                )
                .build(),
            ShortcutInfoCompat.Builder(this, "shortcut_entry_qr")
                .setShortLabel("入校码")
                .setLongLabel("入校码")
                .setIcon(IconCompat.createWithResource(this, R.drawable.entry_qr_shortcut))
                .setIntent(
                    Intent().apply {
                        component = launcherComponent
                        action = Intent.ACTION_VIEW
                        data = Uri.parse("wpy://wpy.app/entryQr")
                    }
                )
                .build(),
        )
        ShortcutManagerCompat.setDynamicShortcuts(this, shortcuts)
    }

    private fun getCurrentLauncherComponent(): ComponentName {
        val enabledAlias = iconAliases.firstOrNull { alias ->
            packageManager.getComponentEnabledSetting(ComponentName(this, alias)) ==
                    PackageManager.COMPONENT_ENABLED_STATE_ENABLED
        }
        return ComponentName(this, enabledAlias ?: "com.twt.service.MainActivity")
    }

    private fun restartApp(result: MethodChannel.Result) {
        runCatching {
            val component = packageManager.getLaunchIntentForPackage(packageName)?.component
            if (component == null) {
                result.error("NO_LAUNCH_INTENT", "Cannot find launch intent", "")
                return
            }
            startActivity(Intent.makeRestartActivityTask(component))
            Runtime.getRuntime().exit(0)
        }.onFailure {
            result.error("RESTART_FAILED", it.message, "")
        }.onSuccess {
            result.success(null)
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
            HotFixPreference.getCanUseFixSo()?.let {
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
        HotFixPreference.setCurrentUseSoFileCanUse()
    }

    // 禁用文字大小改变
    override fun attachBaseContext(newBase: Context) {
        ChangeDisplay.changeConfig(newBase)
        super.attachBaseContext(newBase)
    }

    // 更改字体大小后，自动重启activity（参考了高德地图）
    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        ChangeDisplay.recreateWhenConfigChange(newConfig, this)
    }

}
