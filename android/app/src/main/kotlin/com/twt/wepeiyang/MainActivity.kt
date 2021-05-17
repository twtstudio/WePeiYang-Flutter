package com.twt.wepeiyang

import android.app.AlertDialog
import android.app.PendingIntent
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.example.umeng_sdk.UmengSdkPlugin
import com.umeng.analytics.MobclickAgent
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference


class MainActivity : FlutterFragmentActivity() {
    var messageChannel: MethodChannel? = null
    private var notificationManager: NotificationManagerCompat? = null

    override fun onPause() {
        super.onPause()
        MobclickAgent.onPause(this)
        Log.i("UMLog", "onPause@MainActivity")
    }

    override fun onResume() {
        super.onResume()
        MobclickAgent.onResume(this)
        Log.i("UMLog", "onResume@MainActivity")
    }

    fun showNotification(data: FeedbackMessage) {
        //点击时想要打开的界面
        //点击时想要打开的界面
        val intent = Intent(this, MainActivity::class.java)
        intent.data = Uri.parse(data.question_id.toString())
        //一般点击通知都是打开独立的界面，为了避免添加到现有的activity栈中，可以设置下面的启动方式
//        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK

        //创建activity类型的pendingIntent，还可以创建广播等其他组件
        val pendingIntent = PendingIntent.getActivity(this, 0, intent, 0)

        val builder = NotificationCompat.Builder(this, "1")
                .setSmallIcon(R.drawable.push_small)
                .setContentTitle(data.title)
                .setContentText(data.content)
//                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
//                .setDefaults(NotificationCompat.DEFAULT_ALL)
                .setContentIntent(pendingIntent)
                .setWhen(System.currentTimeMillis())
                .setAutoCancel(true)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Log.d("WBYDemo", "Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP")
            val intent2 = Intent(this, MainActivity::class.java)
            val pIntent = PendingIntent.getActivity(applicationContext, 1, intent2, PendingIntent.FLAG_UPDATE_CURRENT)
            builder.setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            builder.setFullScreenIntent(pIntent, false)
        }

        //notificationId 相当于通知的唯一标识，用于更新或者移除通知
        notificationManager?.notify(data.question_id, builder.build())
    }

    override fun onNewIntent(intent: Intent) {
        intent.dataString?.let {
            Log.d("WBYDEMO", it)
            WBYApplication.postId = it.toIntOrNull() ?: -1
            messageChannel?.invokeMethod("getReply", null, object : MethodChannel.Result {
                override fun success(result: Any?) {
//                                TODO("Not yet implemented")
                    WBYApplication.postId = -1
                }

                override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
//                                TODO("Not yet implemented")
                }

                override fun notImplemented() {
//                                TODO("Not yet implemented")
                }

            })
        }

        super.onNewIntent(intent)
    }


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        messageChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.twt.wepeiyang/message").apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "getPostId" -> {
                        result.success(WBYApplication.postId)
                    }
                    "cancelNotification" -> {
                        try {
                            call.argument<Int>("id")
                        } catch (e: Exception) {
                            -1
                        }.takeIf { it != -1 }?.let {
                            notificationManager?.cancel(it)
                        }
                        result.success("cancel success")
                    }
                    else -> result.error("-1", "cannot find method", null)
                }
            }
        }
        super.configureFlutterEngine(flutterEngine)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WBYApplication.activity = WeakReference(this)
        UmengSdkPlugin.setContext(this)
        notificationManager = NotificationManagerCompat.from(this)
        Log.i("UMLog", "UMConfigure.init@MainActivity")
//        GlobalScope.launch {
//            delay(5000)
//            showNotification(FeedbackMessage(title = "test", content = "test", question_id = 824))
//        }
    }

    // 这么写没用，但是先留着，如果之后有厂商推送就有用了
    override fun getInitialRoute(): String {
        WBYApplication.postId.takeIf { it != -1 }?.let {
            return "feedback/detail"
        }
        return super.getInitialRoute()
    }

    fun showDialog(data: String) {
        val builder = AlertDialog.Builder(this)
        builder.setPositiveButton("确定", null)
        builder.setTitle(data)
        builder.show()
    }
}
