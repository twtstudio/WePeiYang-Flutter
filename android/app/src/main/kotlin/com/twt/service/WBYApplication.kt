package com.twt.service

import android.app.ActivityManager
import android.app.Application
import android.content.Context
import android.os.Process
import com.twt.service.hot_fix.WbyFixFlutterLoader
import com.twt.service.push.model.Event
import com.twt.service.statistics.WbyStatisticsPlugin
import com.umeng.commonsdk.UMConfigure
import io.flutter.FlutterInjector
import java.lang.ref.WeakReference

class WBYApplication : Application() {
    companion object {
        var context: WeakReference<Context>? = null
        var eventList = mutableListOf<Event>().apply { add(Event(-1, "null")) }
        const val TAG = "WBY_RESTART"
    }

    override fun onCreate() {
        super.onCreate()
        runOnMainProcess {
            context = WeakReference(applicationContext)
            // 初始化友盟
            if (BuildConfig.LOG_OUTPUT) {
                WbyStatisticsPlugin.log("log output")
                UMConfigure.setLogEnabled(true)
            }
            WbyStatisticsPlugin.log("preInit umeng sdk")
            UMConfigure.preInit(applicationContext, "60464782b8c8d45c1390e7e3", "android")
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
                if (appProcess.pid == pid && appProcess.processName == "com.twt.service") {
                    return@takeIf true
                }
            }
            false
        }?.invoke()
    }
}

fun getCurProcessName(): String {
    // 获取此进程的标识符
    WBYApplication.context?.get()?.apply {
        val pid = Process.myPid()
        // 获取活动管理器
        val activityManager = getSystemService(Application.ACTIVITY_SERVICE) as ActivityManager

        // 从应用程序进程列表找到当前进程，是：返回当前进程名
        for (appProcess in activityManager.runningAppProcesses) {
            if (appProcess.pid == pid) {
                return appProcess.processName
            }
        }
    }
    return "unknown"
}