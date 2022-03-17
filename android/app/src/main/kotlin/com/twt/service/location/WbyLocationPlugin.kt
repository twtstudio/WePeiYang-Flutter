package com.twt.service.location

import com.twt.service.common.LogUtil
import com.twt.service.common.WbyPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class WbyLocationPlugin : WbyPlugin() {

    override val name: String
        get() = "com.twt.service/place"

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getLocation" -> {
                kotlin.runCatching {
                    AMapFactory.init(context, result).startLocation()
                }.onFailure {
                    log(it.toString())
                    result.error(START_LOCATION_ERROR, "start location failure", it.message)
                }
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        const val TAG = "WBY_MAP"
        const val START_LOCATION_ERROR = "START_LOCATION_ERROR"
        fun log(message: String) = LogUtil.d(TAG, message)
    }
}
