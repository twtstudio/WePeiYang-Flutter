package com.example.wei_pei_yang_demo.alarm

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import com.example.wei_pei_yang_demo.MainActivity
import com.example.wei_pei_yang_demo.R

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        val text: String? = intent?.getStringExtra("text")
        showNotification(context, text)
        context?.let {
            intent?.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            intent?.setClass(it, AlarmService::class.java)
            it.startService(intent)
        }
    }

    private fun showNotification(context: Context?, text: String?) {
        val manager = context?.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        // TODO 跳转至课程表页面，记得返回时要返回主页，所以要修改Navigator栈
        // Intent中的Activity为点击通知后跳转至的页面
        val ctxIntent =
                PendingIntent.getActivity(context, 0, Intent(context, MainActivity::class.java), 0)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(
                    NotificationChannel(
                            "wpy",
                            "schedule",
                            NotificationManager.IMPORTANCE_HIGH
                    ).apply {
                        // TODO 一些设置
                    }
            )
        }
        val notifyBuild = NotificationCompat.Builder(context, "wpy")
                .setContentTitle("上课提醒")
                .setContentText(text)
                .setAutoCancel(true)
                .setGroup("schedule")
                .setGroupSummary(false)
                .setContentIntent(ctxIntent)
//            .setLargeIcon()
                .setSmallIcon(R.mipmap.ic_launcher)
                .setShowWhen(true).build().apply {
                    // TODO 一些设置
//                visibility = Notification.VISIBILITY_PUBLIC
                }
        manager.notify(500, notifyBuild)
    }
}