package com.twt.service.message

import android.content.Context
import android.util.Log
import com.twt.service.WBYApplication
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

// 由于 flutter 引擎初始化有延迟，所以选择在进入微北洋主页后主动查看 eventList 中是否由未处理事件
class WbyMessagePlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "com.twt.service/message")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getLastEvent" -> {
                with(WBYApplication.eventList) {
                    val event = last()
                    if (size > 1) {
                        removeLast()
                    }
                    Log.d(TAG, "WBYApplication.eventList: $this")
                    if (event.type != -1) {
                        Log.d(TAG, event.toString())
                        result.success(
                                mapOf(
                                        "event" to event.type,
                                        "data" to event.data
                                )
                        )
                    }
                }
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        const val TAG = "WBY_MESSAGE"
    }
}