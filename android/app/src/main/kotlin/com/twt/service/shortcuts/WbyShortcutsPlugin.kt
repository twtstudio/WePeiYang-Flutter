/*package com.twt.service.shortcuts

//import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
import com.twt.service.common.WbyPlugin
/**
 * 微北洋一般的[FlutterPlugin]的通用格式
 */
abstract class WbyShorcutsPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    lateinit var channel: MethodChannel

    lateinit var context: Context

    /**
     * channel 的名字，由于微北洋中一般的插件都只有一个 channel，所以也将它裁剪后作为 log 的 TAG
     */
    abstract val name: String

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        LogUtil.d("WbyShortcutsPlugin", name)
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, name)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}