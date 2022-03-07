package com.twt.service

import android.app.Application
import android.content.Context
import android.util.Log
import com.twt.service.hot_fix.WbyFixFlutterLoader
import com.twt.service.push.model.Event
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
        context = WeakReference(applicationContext)
        FlutterInjector.instance().flutterLoader().startInitialization(this)
        // TODO: android 分渠道打包
        if (BuildConfig.LOG_OUTPUT){
            UMConfigure.setLogEnabled(true)
        }
        UMConfigure.preInit(this,"60464782b8c8d45c1390e7e3","android");
//        initFlutterEngine()
    }

    // 用反射的方式重置 flutter 启动目录
    @Suppress("unused")
    private fun initFlutterEngine() {
        val flutterInjector =
            FlutterInjector.Builder().setFlutterLoader(WbyFixFlutterLoader()).build()
        FlutterInjector.setInstance(flutterInjector)
        FlutterInjector.instance().flutterLoader().startInitialization(this)
    }
}