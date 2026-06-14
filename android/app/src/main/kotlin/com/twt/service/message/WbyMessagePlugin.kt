package com.twt.service.message

import com.twt.service.WBYApplication
import com.twt.service.common.LogUtil
import com.twt.service.common.WbyPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

// 由于 flutter 引擎初始化有延迟，所以选择在进入微北洋主页后主动查看 eventList 中是否由未处理事件
class WbyMessagePlugin : WbyPlugin() {

    override val name: String
        get() = "com.twt.service/message"

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        super.onAttachedToEngine(binding)
        channelRef = channel
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        if (channelRef == channel) channelRef = null
        super.onDetachedFromEngine(binding)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getLastEvent" -> {
                val event = EventDispatcher.nextEvent()
                if (event == null) {
                    result.success(null)
                    return
                }
                log("WBYApplication.eventList: ${WBYApplication.eventList}")
                log(event.toString())
                result.success(
                    mapOf(
                        "event" to event.type,
                        "data" to event.data
                    )
                )
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        const val TAG = "MESSAGE"
        private var channelRef: MethodChannel? = null
        fun log(message: String) = LogUtil.d(TAG, message)

        fun notifyEventChanged() {
            log("notifyEventChanged")
            channelRef?.invokeMethod("eventChanged", null)
        }
    }
}
