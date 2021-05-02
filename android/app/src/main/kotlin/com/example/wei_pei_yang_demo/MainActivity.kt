package com.example.wei_pei_yang_demo

import android.app.AlertDialog
import android.app.PendingIntent
import android.content.*
import android.database.sqlite.SQLiteDatabase
import android.net.Uri
import android.os.Bundle
import android.util.Log
import androidx.activity.viewModels
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.work.*
import com.example.umeng_sdk.UmengSdkPlugin
import com.example.wei_pei_yang_demo.alarm.AlarmService
import com.example.wei_pei_yang_demo.alarm.ScheduleDatabase
import com.umeng.analytics.MobclickAgent
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.lang.ref.WeakReference
import java.util.*


class MainActivity : FlutterFragmentActivity() {
    private val notifyChannel = "com.example.wei_pei_yang_demo/notify"
    var messageChannel: MethodChannel? = null

    val model by viewModels<MainActivityViewModel>()

    override fun onPause() {
        super.onPause()
        MobclickAgent.onPause(this)
        android.util.Log.i("UMLog", "onPause@MainActivity")
    }

    override fun onResume() {
        super.onResume()
        MobclickAgent.onResume(this)
        android.util.Log.i("UMLog", "onResume@MainActivity")
    }

    private fun showNotification() {
        //点击时想要打开的界面
        //点击时想要打开的界面
        val intent = Intent(this, MainActivity::class.java)
        intent.setData(Uri.parse("824"))
        //一般点击通知都是打开独立的界面，为了避免添加到现有的activity栈中，可以设置下面的启动方式
//        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK

        //创建activity类型的pendingIntent，还可以创建广播等其他组件
        val pendingIntent = PendingIntent.getActivity(this, 0, intent, 0)

        val builder: NotificationCompat.Builder = NotificationCompat.Builder(this, "1")
                .setSmallIcon(R.drawable.ok)
                .setContentTitle("My notification")
                .setContentText("Hello World!")
                .setPriority(NotificationCompat.PRIORITY_DEFAULT) //设置pendingIntent
                .setContentIntent(pendingIntent) //设置点击后是否自动消失
                .setAutoCancel(true)

        val notificationManager = NotificationManagerCompat.from(this)
        //notificationId 相当于通知的唯一标识，用于更新或者移除通知
        notificationManager.notify(1, builder.build())
    }

    override fun onNewIntent(intent: Intent) {
        intent.dataString?.let {
            Log.d("WBYDEMO", it)
            WBYApplication.postId = it.toInt()
            messageChannel?.invokeMethod("getReply", null , object : MethodChannel.Result {
                override fun success(result: Any?) {
//                                TODO("Not yet implemented")
                    WBYApplication.postId = null;
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
        MethodChannel(flutterEngine.dartExecutor, notifyChannel).setMethodCallHandler { call, result ->
            when (call.method) {
                "setData" -> {
                    stopAlarmService()
                    call.argument<List<Map<String, Any>>>("list")?.let { setData(this@MainActivity, it) }
                    startAlarmService()
                    result.success("success")
                }
                "setStatus" -> {
                    call.argument<Boolean>("bool")?.let {
                        if (it) startAlarmService()
                        else stopAlarmService()
                    }
                }
                else -> result.error("-1", "cannot find method", null)
            }
        }
        messageChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.wei_pei_yang_demo/message").apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "refreshFeedbackMessage" -> {
                        model.refreshFeedbackMessage(result)
                    }
                    "setMessageReadById" -> {
                        Log.d("WBYFEEDBACKREAD", "123")
                        model.setMessageReadById(result, call.argument<Int>("id"))
                    }
                    "getPostId" -> {
                        WBYApplication.postId?.let {
                            WBYApplication.postId = null
                            return@setMethodCallHandler result.success(it)
                        }
                        result.error("-1", "can not find post id", null)
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
        android.util.Log.i("UMLog", "UMConfigure.init@MainActivity")
        GlobalScope.launch {
            delay(5000)
            showNotification()
        }
    }

    // 这么写没用，但是先留着，如果之后有厂商推送就有用了
    override fun getInitialRoute(): String {
        WBYApplication.postId?.let {
            return "feedback/detail";
        }
        return super.getInitialRoute();
    }

    private fun setData(context: Context?, data: List<Map<String, Any>>) {
        object : Thread() {
            override fun run() {
                val scheduleSQL = ScheduleDatabase(context, "Schedule.db", null, 1)
                val db: SQLiteDatabase = scheduleSQL.writableDatabase
                // 删除之前的所有数据
                db.delete("Schedule_data", null, null)
                with(ContentValues()) {
                    data.forEach {
                        this.put("time", it["time"] as Int)
                        this.put("name", it["name"] as String)
                        db.insert("Schedule_data", null, this)
                        this.clear()
                    }
                }
                startAlarmService() // 数据添加完毕后再开启service
            }
        }.start()
    }

    private fun startAlarmService() {
        startService(Intent(this, AlarmService::class.java))
    }

    private fun stopAlarmService() {
        stopService(Intent(this, AlarmService::class.java))
    }

    fun showDialog(data: String) {
        val builder = AlertDialog.Builder(this);
        builder.setPositiveButton("确定", null);
        builder.setTitle(data);
        builder.show();
    }

}
