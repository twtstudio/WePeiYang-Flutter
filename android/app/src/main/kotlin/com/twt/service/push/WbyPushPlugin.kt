package com.twt.service.push

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationManagerCompat
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.igexin.sdk.PushManager
import com.twt.service.BuildConfig
import com.twt.service.MainActivity
import com.twt.service.WBYApplication
import com.twt.service.common.IntentEvent
import com.twt.service.push.model.Event
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry


class WbyPushPlugin : FlutterPlugin, MethodChannel.MethodCallHandler,
    PluginRegistry.NewIntentListener, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var receiver: PushBroadCastReceiver
    private lateinit var binding: ActivityPluginBinding
    private val pushManager by lazy { PushManager.getInstance() }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "com.twt.service/push")
        context = binding.applicationContext
        channel.setMethodCallHandler(this)
        createNotificationChannel()
        initSdk()
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "turnOnPushService" -> {
                if (!pushManager.isPushTurnedOn(context)) {
                    Log.d(TAG, "turnOnPushService")
                    pushManager.turnOnPush(context)
                }
            }
            "getCid" -> {
                if (pushManager.isPushTurnedOn(context)) {
                    result.success(pushManager.getClientid(context))
                } else {
                    result.error("", "", "")
                }
            }
            "cancelNotification" -> {
                call.argument<Int>("id")?.let {
                    NotificationManagerCompat.from(context).cancel(it)
                }
                result.success("cancel success")
            }
            "turnOffPushService" -> {
                if (pushManager.isPushTurnedOn(context)) {
                    pushManager.turnOffPush(context)
                }
            }
            "cancelAllNotification" -> {
                NotificationManagerCompat.from(context).cancelAll()
            }
            "getIntentUri" -> {
                getIntentUri(call,result)
            }
            else -> result.notImplemented()
        }
    }

    override fun onNewIntent(intent: Intent?): Boolean {
        intent?.let {
            handleIntent(it)
            return true
        }
        return false
    }

    private fun handleIntent(intent: Intent) {
        // 华为和小米厂商通道可以传递 data ，魅族厂商通道只能产地 extra ，所以只通过 extra 传递数据
        when (intent.getStringExtra("type")) {
            "feedback" -> {
                val id = intent.getIntExtra("question_id", -1)
                Log.d(TAG, "question_id : $id")
                WBYApplication.eventList.add(
                    Event(IntentEvent.FeedbackPostPage.type, id)
                )
            }
            "mailbox" -> {
                val url = intent.getStringExtra("url")
                val title = intent.getStringExtra("title")
                val data = mapOf("url" to url, "title" to title)
                WBYApplication.eventList.add(
                    Event(IntentEvent.MailBox.type, data)
                )
            }
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        handleIntent(binding.activity.intent)
        val intentFilter = IntentFilter()
        receiver = PushBroadCastReceiver(binding, channel)
        this.binding = binding
        val localBroadcastManager = LocalBroadcastManager.getInstance(context)
        Log.d(TAG, context.applicationContext.toString())
        intentFilter.addAction(DATA)
        intentFilter.addAction(CID)
        intentFilter.addDataScheme("twtstudio")
        localBroadcastManager.registerReceiver(receiver, intentFilter)
        binding.addOnNewIntentListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    override fun onDetachedFromActivity() {
        LocalBroadcastManager.getInstance(context).unregisterReceiver(receiver)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "通知"
            val description = "横幅，锁屏"
            //不同的重要程度会影响通知显示的方式
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel("1", name, importance)
            channel.description = description
            channel.setSound(null, null)
            channel.vibrationPattern = longArrayOf(0, 1000, 500, 1000)
            channel.enableVibration(true)
            val notificationManager = context.getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun initSdk() {
        pushManager.initialize(context)
        pushManager.turnOffPush(context)
        if (BuildConfig.DEBUG) {
            pushManager.setDebugLogger(context) { s -> Log.i(TAG, s) }
        }
    }

    private fun getIntentUri(call:MethodCall,result: MethodChannel.Result) {
        val intent = Intent(context, MainActivity::class.java).apply {
            setPackage(context.packageName)
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }

        when(call.argument<String>("type")){
            "feedback" -> {
                val id = call.argument<Int>("question_id")
                if (id == null){
                    result.error("-1","question_id can't be null!","")
                    return
                }

                val intentUri = intent.apply {
                    data = Uri.parse("twtstudio://weipeiyang.app/feedback?")
                    putExtra("question_id", id)
                }.toUri(Intent.URI_INTENT_SCHEME)

                result.success(intentUri)
            }
            "mailbox" -> {
                val url = call.argument<String>("url")
                val title = call.argument<String>("title")
                if (url.isNullOrBlank() || title.isNullOrBlank()){
                    result.error("-1","url and title can't be null!","")
                    return
                }

                val intentUri = intent.apply {
                    data = Uri.parse("twtstudio://weipeiyang.app/mailbox?")
                    putExtra("url", "www.twt.edu.cn")
                    putExtra("title","twt")
                }.toUri(Intent.URI_INTENT_SCHEME)

                result.success(intentUri)
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        const val DATA = "com.twt.service.PUSH_DATA"
        const val CID = "com.twt.service.PUSH_TOKEN"
        const val TAG = "WBY_PUSH"
    }
}
