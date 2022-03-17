package com.twt.service.widget

import android.content.Intent
import com.twt.service.WBYApplication
import com.twt.service.common.LogUtil
import com.twt.service.common.WbyPlugin
import com.twt.service.push.IntentEvent
import com.twt.service.push.model.Event
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class WbyWidgetPlugin : WbyPlugin(), ActivityAware, PluginRegistry.NewIntentListener {
    private lateinit var binding: ActivityPluginBinding

    override val name: String
        get() = "com.twt.service/widget"

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "refreshScheduleWidget" -> {
                updateWidget()
            }
            else -> result.notImplemented()
        }
    }

    private fun updateWidget() {
        val intent = Intent(binding.activity, ScheduleCardWidgetProvider::class.java).apply {
            action = "com.twt.appwidget.refresh"
        }
        context.sendBroadcast(intent)
    }

    override fun onNewIntent(intent: Intent?): Boolean {
        intent?.runCatching {
            return handleIntent(this)
        }
        return false
    }

    private fun handleIntent(intent: Intent): Boolean {
        log("WbyWidgetPlugin handle intent :" + intent.dataString)
        if (intent.data?.host?.equals("weipeiyang.app") == true) {
            intent.data?.let {
                when (it.path) {
                    "/schedule" -> {
                        WBYApplication.eventList.add(
                            Event(
                                IntentEvent.SchedulePage.type,
                                "go to schedule page without data"
                            )
                        )
                        return true
                    }
                    else -> {}
                }
            }
        }

        return false
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        runCatching {
            handleIntent(binding.activity.intent)
        }
        binding.addOnNewIntentListener(this)
        this.binding = binding
        updateWidget()
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    override fun onDetachedFromActivity() {}

    companion object {
        const val TAG = "WBY_WIDGET"
        fun log(message: String) = LogUtil.d(TAG, message)
    }
}