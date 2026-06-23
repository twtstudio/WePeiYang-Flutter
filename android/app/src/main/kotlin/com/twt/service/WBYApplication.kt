package com.twt.service

import android.app.ActivityManager
import android.app.Application
import android.content.Context
import android.os.Process
import com.twt.service.hot_fix.HotFixPreference
import com.twt.service.push.model.Event
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
            // Build 类获取系统信息
            // https://blog.csdn.net/duyiqun/article/details/54882735
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

    // 个推会创建一条子进程用来接收推送，所以flutter初始化只能在主进程执行
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