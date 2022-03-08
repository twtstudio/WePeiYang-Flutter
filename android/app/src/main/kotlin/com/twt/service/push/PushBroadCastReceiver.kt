package com.twt.service.push

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.work.*
import com.google.gson.Gson
import com.twt.service.MainActivity
import com.twt.service.R
import com.twt.service.common.BASEURL
import com.twt.service.push.model.Event
import com.twt.service.push.model.FeedbackMessage
import com.twt.service.push.model.MailBoxMessage
import com.twt.service.push.model.MessageData
import com.twt.service.push.server.PushCIdWorker
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

// TODO: 当应用与个推服务器连接，且处于后台时，若发送透传，需要转换成notification
class PushBroadCastReceiver(
        private val binding: ActivityPluginBinding,
        private val channel: MethodChannel
) : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        kotlin.runCatching {
            WbyPushPlugin.log("PushBroadCastReceiver receive intent :" + intent?.extras.toString()
                    ?: "no data")
            when (intent?.action) {
                WbyPushPlugin.DATA -> {
                    intent.getStringExtra("data")?.let {
                        val eventData = Gson().toJson(Gson().fromJson(it, Event::class.java).data)
                        WbyPushPlugin.log(eventData)
                        val formData = Gson().fromJson(eventData, MailBoxMessage::class.java)
                        WbyPushPlugin.log(formData.toString())
                        showNotification(formData)
                    }
                }
                WbyPushPlugin.CID -> {
                    val cId = intent.getStringExtra("cid")
                    WbyPushPlugin.log("PushBroadCastReceiver receive cid :" + (cId ?: "no data"))
                    val workManager = WorkManager.getInstance(binding.activity.applicationContext)
                    val constraints = Constraints.Builder()
                            .setRequiredNetworkType(NetworkType.CONNECTED)
                            .setRequiresStorageNotLow(true)
                            .build()
                    val task = OneTimeWorkRequest.Builder(PushCIdWorker::class.java)
                            .addTag("1")
                            .setInputData(workDataOf("cid" to cId))
                            .setConstraints(constraints)
                            .build()
                    workManager.enqueueUniqueWork("download", ExistingWorkPolicy.KEEP, task)
                }
                else -> {}
            }
        }
    }

    private fun showNotification(data: MessageData) {
        val notificationManager = NotificationManagerCompat.from(binding.activity)
        fun send(id: Int, title: String, content: String, intent: Intent) {
            val pendingIntent = PendingIntent.getActivity(binding.activity, 0, intent, 0)
            val builder = NotificationCompat.Builder(binding.activity, "1")
                    .setSmallIcon(R.drawable.push_small)
                    .setContentTitle(title)
                    .setContentText(content)
                    .setContentIntent(pendingIntent)
                    .setWhen(System.currentTimeMillis())
                    .setAutoCancel(true)

            WbyPushPlugin.log("Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP")
            val intent2 = Intent(binding.activity, MainActivity::class.java)
            val pIntent = PendingIntent.getActivity(
                    binding.activity.applicationContext,
                    1,
                    intent2,
                    PendingIntent.FLAG_IMMUTABLE
            )
            builder.setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            builder.setFullScreenIntent(pIntent, false)
            notificationManager.notify(id, builder.build())
        }

        // 点击时想要打开的界面
        val intent = Intent(binding.activity, MainActivity::class.java)

        when (data) {
            is FeedbackMessage -> {
                // 一般点击通知都是打开独立的界面，为了避免添加到现有的activity栈中，可以设置下面的启动方式
                // intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                intent.apply {
                    this.data = Uri.parse("${BASEURL}feedback?")
                    putExtra("question_id", data.question_id)
                }
                send(data.question_id, data.title, data.content, intent)
            }
            is MailBoxMessage -> {
                intent.apply {
                    this.data = Uri.parse("${BASEURL}mailbox?")
                    putExtra("url", data.url)
                    putExtra("title", data.title)
                }
                send(0, data.title, data.content, intent)
            }
        }
    }
}