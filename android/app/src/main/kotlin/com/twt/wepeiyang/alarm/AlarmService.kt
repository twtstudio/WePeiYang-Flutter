package com.twt.wepeiyang.alarm

import android.app.AlarmManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.os.IBinder

class AlarmService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        setAlarm()
        return START_REDELIVER_INTENT // 提高service的优先级
    }

    private fun setAlarm() {
        val scheduleSQL = ScheduleDatabase(this, "Schedule.db", null, 1)
        val db: SQLiteDatabase = scheduleSQL.writableDatabase
        val cursor: Cursor = db.query("Schedule_data", null, null, null, null, null, null)
        var time: Long?
        var name = ""
        if (cursor.moveToFirst()) { // 先用游标取出第一条数据
            time = cursor.getLong(cursor.getColumnIndex("time"))
            name = cursor.getString(cursor.getColumnIndex("name"))
            do { // 遍历接下来的数据，寻找最近的时间（说白了就是选择排序）
                if (time!! > cursor.getLong(cursor.getColumnIndex("time"))) {
                    time = cursor.getLong(cursor.getColumnIndex("time"))
                    name = cursor.getString(cursor.getColumnIndex("name"))
                }
            } while (cursor.moveToNext())
        } else {
            time = null
        }
        db.delete("Schedule_data", "time=?", arrayOf(time.toString()))
        cursor.close() // 记得关闭游标
        val startNotification = Intent(this, AlarmReceiver::class.java)
        startNotification.putExtra("text", name)
        val alarmManager = getSystemService(ALARM_SERVICE) as AlarmManager
        val pendingIntent = PendingIntent.getBroadcast(
                this,
                0,
                startNotification,
                PendingIntent.FLAG_UPDATE_CURRENT
        )
        // 如果time非空，提交事件；否则关闭服务，下次添加课程数据时再开启
        time?.let {
            alarmManager.set(AlarmManager.RTC_WAKEUP, time, pendingIntent)
        } ?: stopService(Intent(this, AlarmService::class.java))
    }
}