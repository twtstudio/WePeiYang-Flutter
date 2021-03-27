package com.example.wei_pei_yang_demo

import android.app.AlertDialog
import android.content.*
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import android.database.sqlite.SQLiteDatabase
import android.os.Bundle
import android.util.Log
import androidx.activity.viewModels
import androidx.work.*
import com.example.wei_pei_yang_demo.alarm.AlarmService
import com.example.wei_pei_yang_demo.alarm.ScheduleDatabase
import io.flutter.embedding.android.FlutterFragmentActivity
import java.lang.ref.WeakReference
import java.util.*


class MainActivity : FlutterFragmentActivity() {
    private val notifyChannel = "com.example.wei_pei_yang_demo/notify"
    var messageChannel: MethodChannel? = null

    val model by viewModels<MainActivityViewModel>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
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
                        Log.d("WBYFEEDBACKREAD","123")
                        model.setMessageReadById(result, call.argument<Int>("id"))
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
