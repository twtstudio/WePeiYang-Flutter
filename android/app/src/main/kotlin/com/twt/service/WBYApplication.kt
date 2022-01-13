package com.twt.service

import android.app.Application
import android.content.Context
import android.util.Log
import com.twt.service.push.model.Event
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.loader.FlutterApplicationInfo
import io.flutter.embedding.engine.loader.FlutterLoader
import java.io.File
import java.lang.ref.WeakReference

class WBYApplication : Application() {
    companion object {
        var context: WeakReference<Context>? = null
        var eventList = mutableListOf<Event>().apply { add(Event(-1, "null")) }
        const val TAG = ""
    }

    override fun onCreate() {
        super.onCreate()
        Log.d("WBY_RESTART","重新打开微北洋")
        context = WeakReference(applicationContext)
        FlutterInjector.instance().flutterLoader().startInitialization(this)
    }

    // 用反射的方式重置 flutter 启动目录
    @Suppress("unused")
    private fun initFlutterEngine() {
        FlutterInjector.instance().flutterLoader().runCatching {
            File(filesDir, "fix_app.so").takeIf { it.exists() }?.let { file ->
                Log.d(TAG, "fix file : ${file.absolutePath}")
                val flutterApplicationInfoField =
                    FlutterLoader::class.java.getDeclaredField("flutterApplicationInfo")
                flutterApplicationInfoField.isAccessible = true
                val flutterApplicationInfo =
                    flutterApplicationInfoField.get(this) as FlutterApplicationInfo

                val aotSharedLibraryNameField =
                    FlutterApplicationInfo::class.java.getDeclaredField("aotSharedLibraryName")
                aotSharedLibraryNameField.isAccessible = true
                aotSharedLibraryNameField.set(flutterApplicationInfo, file.absolutePath)

                Log.i(
                    TAG,
                    "load so name:" + aotSharedLibraryNameField.get(flutterApplicationInfo)
                )
            }
        }.onFailure {
            Log.d(TAG, it.toString())
        }.onSuccess {
            Log.d(TAG, "hot fix success : $it")
            FlutterInjector.instance().flutterLoader().startInitialization(this)
        }
    }
}