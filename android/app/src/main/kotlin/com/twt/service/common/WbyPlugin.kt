package com.twt.service.common

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel

/**
 * 微北洋一般的[FlutterPlugin]的通用格式
 */
abstract class WbyPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    lateinit var channel: MethodChannel

    /**
     * [FlutterPlugin.FlutterPluginBinding.applicationContext]
     *
     * 由于 Activity 在配置修改的时候会重建，所以很容易想到 FlutterPlugin 中不可能保存 Activity 的 context
     */
    lateinit var context: Context

    /**
     * channel 的名字，由于微北洋中一般的插件都只有一个 channel，所以也将它裁剪后作为 log 的 TAG
     */
    abstract val name: String

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        LogUtil.d("WbyPlugin", name)
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, name)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}