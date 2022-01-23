package com.twt.service.hot_fix

import android.content.Context
import android.util.Log
import com.twt.service.WBYApplication
import com.twt.service.common.WbySharePreference
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.loader.FlutterApplicationInfo
import io.flutter.embedding.engine.loader.FlutterLoader
import java.io.File

// https://juejin.cn/post/6921280711462748167
// 不优雅的实现方式 hhh
class WbyFixFlutterLoader : FlutterLoader() {

    override fun ensureInitializationComplete(
        applicationContext: Context,
        args: Array<out String>?
    ) {
        FlutterInjector.instance().flutterLoader().runCatching {
            WbySharePreference.fixSo?.let { path ->
                Log.d(WbyFixPlugin.TAG,"load .so file : $path")
                File(path).let { file ->
                    Log.d(WBYApplication.TAG, "fix file : ${file.absolutePath}")
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
                        WBYApplication.TAG,
                        "load so name:" + aotSharedLibraryNameField.get(flutterApplicationInfo)
                    )
                }
            }
        }.onFailure {
            Log.d(WBYApplication.TAG, it.toString())
        }.onSuccess {
            Log.d(WBYApplication.TAG, "hot fix success : $it")
        }
        super.ensureInitializationComplete(applicationContext, args)
    }
}