package com.twt.service.location

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class WbyLocationPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var context:Context
    private lateinit var placeChannel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        placeChannel = MethodChannel(binding.binaryMessenger,"com.twt.service/place")
        placeChannel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        placeChannel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getLocation" -> {
                kotlin.runCatching {
                    AMapFactory.init(placeChannel, context).startLocation()
                }.onSuccess {
                    result.success("begin")
                }.onFailure {
                    result.error(START_LOCATION_ERROR,"start location failure",it.message)
                }
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        const val TAG = "WBY_MAP"
        const val START_LOCATION_ERROR = "START_LOCATION_ERROR"
    }
}
