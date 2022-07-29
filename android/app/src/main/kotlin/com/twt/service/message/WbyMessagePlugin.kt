package com.twt.service.message

import com.twt.service.WBYApplication
import com.twt.service.common.LogUtil
import com.twt.service.common.WbyPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

// 由于 flutter 引擎初始化有延迟，所以选择在进入微北洋主页后主动查看 eventList 中是否由未处理事件
class WbyMessagePlugin : WbyPlugin() {

    override val name: String
        get() = "com.twt.service/message"

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getLastEvent" -> {
                with(WBYApplication.eventList) {
                    val event = last()
                    if (size > 1) {
                        removeLast()
                    }
                    log("WBYApplication.eventList: $this")
                    if (event.type != -1) {
                        log(event.toString())
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
        const val TAG = "MESSAGE"
        fun log(message: String) = LogUtil.d(TAG, message)
    }
}