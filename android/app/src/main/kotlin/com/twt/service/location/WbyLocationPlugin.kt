package com.twt.service.location

import android.view.Gravity
import android.widget.Toast
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
                if ("com.twt.service" == context.applicationInfo.packageName) {
                    kotlin.runCatching {
                        AMapFactory.init(context, result).startLocation()
                    }.onFailure {
                        log(it.toString())
                        result.error(START_LOCATION_ERROR, "start location failure", it.message)
                    }
                } else {
                    Toast.makeText(context,"测试版微北洋不能调用地图接口",Toast.LENGTH_LONG).apply {
                        setGravity(Gravity.CENTER,0,0)
                    }.show()
                    result.error(START_LOCATION_ERROR, "package name error", "")
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
