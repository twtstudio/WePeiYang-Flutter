package com.twt.service.widget

import android.content.Context
import android.content.Intent
import android.util.Log
import com.twt.service.WBYApplication
import com.twt.service.common.IntentEvent
import com.twt.service.common.LogUtil
import com.twt.service.push.WbyPushPlugin
import com.twt.service.push.model.Event
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class WbyWidgetPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware,
    PluginRegistry.NewIntentListener {
    private lateinit var context: Context
    private lateinit var channel: MethodChannel
    private lateinit var binding: ActivityPluginBinding

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "com.twt.service/widget")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

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
        intent?.let {
            handleIntent(it)
            return true
        }
        return false
    }

    private fun handleIntent(intent: Intent) {
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
                    }
                    else -> {

                    }
                }
            }
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        handleIntent(binding.activity.intent)
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