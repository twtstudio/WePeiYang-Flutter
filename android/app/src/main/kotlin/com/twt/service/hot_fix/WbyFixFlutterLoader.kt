package com.twt.service.hot_fix

import android.content.Context
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.loader.FlutterApplicationInfo
import io.flutter.embedding.engine.loader.FlutterLoader
import java.io.File

// https://juejin.cn/post/6921280711462748167
// 不优雅的实现方式
class WbyFixFlutterLoader : FlutterLoader() {

    override fun ensureInitializationComplete(
        applicationContext: Context,
        args: Array<out String>?
    ) {
        FlutterInjector.instance().flutterLoader().runCatching {
            HotFixPreference.getCanUseFixSo()?.let { path ->
                WbyFixPlugin.log("load .so file : $path")
                File(path).let { file ->
                    WbyFixPlugin.log("fix file : ${file.absolutePath}")
                    val flutterApplicationInfoField =
                        FlutterLoader::class.java.getDeclaredField("flutterApplicationInfo")
                    flutterApplicationInfoField.isAccessible = true
                    val flutterApplicationInfo =
                        flutterApplicationInfoField.get(this) as FlutterApplicationInfo

                    val aotSharedLibraryNameField =
                        FlutterApplicationInfo::class.java.getDeclaredField("aotSharedLibraryName")
                    aotSharedLibraryNameField.isAccessible = true
                    aotSharedLibraryNameField.set(flutterApplicationInfo, file.absolutePath)

                    WbyFixPlugin.log(
                        "load so name:" + aotSharedLibraryNameField.get(
                            flutterApplicationInfo
                        )
                    )
                }
            }
        }.onFailure {
            WbyFixPlugin.log(it.toString())
        }.onSuccess {
            WbyFixPlugin.log("hot fix success : $it")
        }
        super.ensureInitializationComplete(applicationContext, args)
    }
}