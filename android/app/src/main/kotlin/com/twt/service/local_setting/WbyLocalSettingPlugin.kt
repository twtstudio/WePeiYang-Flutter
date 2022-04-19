package com.twt.service.local_setting

import android.view.WindowManager
import com.twt.service.common.LogUtil
import com.twt.service.common.WbyPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class WbyLocalSettingPlugin : WbyPlugin(), ActivityAware {
    lateinit var activityBinding: ActivityPluginBinding

    override val name: String
        get() = "com.twt.service/local_setting"

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "changeWindowBrightness" -> changeWindowBrightness(call, result)
                "changeWindowSecure" -> changeWindowSecure(call, result)
            }
        } catch (e: Throwable) {
            result.error("", "", "")
        }
    }

    /**
     * 设置是否可以截屏，默认设置不可以
     */
    private fun changeWindowSecure(call: MethodCall, result: MethodChannel.Result) {
        activityBinding.activity.run {
            if (call.argument<Boolean>("isSecure") != false) {
                if (window.attributes.flags and WindowManager.LayoutParams.FLAG_SECURE != 0) {
                    log("flag already set secure")
                    return
                }
                window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
            } else {
                if (window.attributes.flags and WindowManager.LayoutParams.FLAG_SECURE == 0) {
                    log("flag already set unsecure")
                    return
                }
                window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
            }
        }
        result.success("")
    }

    /**
     * 修改窗口亮度，默认系统亮度
     */
    private fun changeWindowBrightness(call: MethodCall, result: MethodChannel.Result) {
        val brightness = call.argument<Double>("brightness")?.toFloat() ?: -1.0f
        activityBinding.activity.run {
            window.attributes = window.attributes.apply {
                screenBrightness = if (brightness > 1.0 || brightness < 0) -1.0F else brightness
            }
        }
        result.success("")
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityBinding = binding
    }

    override fun onDetachedFromActivity() {}

    companion object {
        const val TAG = "LOCAL_SETTING"
        fun log(msg: String) = LogUtil.d(TAG, msg)
    }
}