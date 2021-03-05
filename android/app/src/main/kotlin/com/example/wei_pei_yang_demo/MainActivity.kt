package com.example.wei_pei_yang_demo

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase

class MainActivity : FlutterActivity() {
    private val notifyChannel = "com.example.wei_pei_yang_demo/notify"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor, notifyChannel).setMethodCallHandler { call, result ->
            if (call.method.equals("notify")) {
                stopAlarmService()
                call.argument<List<Map<String, Any>>>("list")?.let { addData(this@MainActivity, it) }
                result.success("success")
            } else result.error("-1", "cannot find method", null)
        }
        super.configureFlutterEngine(flutterEngine)
    }

    private fun addData(context: Context?, data: List<Map<String, Any>>) {
        object : Thread() {
            override fun run() {
                val scheduleSQL = ScheduleDatabase(context, "Schedule.db", null, 1)
                val db: SQLiteDatabase = scheduleSQL.writableDatabase
                // 删除之前的所有数据
                db.delete("Schedule_data", null, null)
                with(ContentValues()) {
                    data.forEach {
                        this.put("time", it["time"] as Long)
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


}
