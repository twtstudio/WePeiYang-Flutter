package com.twt.service.share

import android.content.Context
import com.tencent.tauth.Tencent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class WbySharePlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var shareChannel: MethodChannel
    private lateinit var context: Context
    private lateinit var activityBinding: ActivityPluginBinding

    private val mTencent: Tencent by lazy {
        Tencent.createInstance(
            APP_ID,
            context,
            APP_AUTHORITIES
        )
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        shareChannel = MethodChannel(binding.binaryMessenger, "com.twt.service/share")
        shareChannel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        shareChannel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "shareToQQ" -> {
                try {
                    QQFactory(mTencent, activityBinding.activity).share(call)
                    result.success("success")
                } catch (e: Exception) {
                    result.error("-1", "cannot share to qq", null)
                }
            }
            "shareImgToQQ" -> {
                try {
                    QQFactory(mTencent, activityBinding.activity).shareImg(call)
                    result.success("success")
                } catch (e: Exception) {
                    result.error("-1", "cannot share img to wx", null)
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
    }

    override fun onDetachedFromActivityForConfigChanges() {
        //
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        //
    }

    override fun onDetachedFromActivity() {
        //
    }

    companion object {
        const val APP_ID = "1104743406"
        const val APP_AUTHORITIES = "com.twt.service.qqprovider"
    }
}