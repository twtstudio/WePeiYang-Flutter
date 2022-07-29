package com.twt.service

import android.app.ActivityManager
import android.app.Application
import android.content.Context
import android.os.Build
import android.os.Process
import com.twt.service.hot_fix.HotFixPreference
import com.twt.service.push.model.Event
import com.umeng.cconfig.RemoteConfigSettings
import com.umeng.cconfig.UMRemoteConfig
import com.umeng.commonsdk.UMConfigure
import io.flutter.FlutterInjector
import java.lang.ref.WeakReference

class WBYApplication : Application() {
    companion object {
        var context: WeakReference<Context>? = null
        var eventList = mutableListOf<Event>().apply { add(Event(-1, "null")) }
    }

    override fun onCreate() {
        super.onCreate()
        runOnMainProcess {
            context = WeakReference(applicationContext)
            // 初始化友盟
            if (BuildConfig.LOG_OUTPUT) {
                UMConfigure.setLogEnabled(true)
            }
            // 友盟在线参数
            UMRemoteConfig.getInstance().apply {
                setDefaults(R.xml.cloud_config_parms)
                setConfigSettings(
                    RemoteConfigSettings.Builder().setAutoUpdateModeEnabled(true).build()
                )
            }
            // Build 类获取系统信息
            // https://blog.csdn.net/duyiqun/article/details/54882735
            UMConfigure.preInit(applicationContext, "60464782b8c8d45c1390e7e3", Build.BRAND)
            // 加载flutter
            FlutterInjector.instance().flutterLoader().startInitialization(this)
        }
    }

    // 用反射的方式重置 flutter 启动目录
//    @Suppress("unused")
//    private fun initFlutterEngine() {
//        val flutterInjector =
//            FlutterInjector.Builder().setFlutterLoader(WbyFixFlutterLoader()).build()
//        FlutterInjector.setInstance(flutterInjector)
//        FlutterInjector.instance().flutterLoader().startInitialization(this)
//    }

    // 个推会创建一条子进程用来接收推送，所以初始化友盟和flutter只能在主进程执行
    fun runOnMainProcess(func: () -> Unit) {
        func.takeIf {
            val pid = Process.myPid()
            val activityManager = getSystemService(ACTIVITY_SERVICE) as ActivityManager
            for (appProcess in activityManager.runningAppProcesses) {
                if (appProcess.pid == pid && appProcess.processName == applicationContext.packageName) {
                    return@takeIf true
                }
            }
            false
        }?.invoke()
    }
}