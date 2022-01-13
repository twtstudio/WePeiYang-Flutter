package com.twt.service.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetManager.ACTION_APPWIDGET_UPDATE
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import android.widget.RemoteViews
import com.twt.service.MainActivity
import com.twt.service.R
import com.twt.service.common.BASEURL
import java.text.SimpleDateFormat
import java.util.*

class ScheduleWidgetProvider : AppWidgetProvider() {
    override fun onEnabled(context: Context?) {
        super.onEnabled(context)
        Log.d("WBY", "课程表小部件被启用")
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == ACTION_APPWIDGET_UPDATE || intent.action == "com.twt.appwidget.refresh") {
            Log.d("WBY", "on refreshing!!!")
            val name = ComponentName(context, ScheduleWidgetProvider::class.java)
            this@ScheduleWidgetProvider.onUpdate(context, AppWidgetManager.getInstance(context), AppWidgetManager.getInstance(context).getAppWidgetIds(name))
        }
        super.onReceive(context, intent)
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        Log.d("WBY", "on updating!!!")
        for (appWidgetId in appWidgetIds) {
            // 小组件整体的点击监听，点击后跳转至MainActivity
            val intent = Intent(context, MainActivity::class.java)
            intent.data = Uri.parse("${BASEURL}schedule")
            val pendingIntent = PendingIntent.getActivity(context, 0, intent, 0)
            val remoteViews = RemoteViews(context.packageName, R.layout.widget_schedule)
            remoteViews.setOnClickPendingIntent(R.id.widget_framelayout, pendingIntent)

            // 小组件日期栏
            remoteViews.setTextViewText(R.id.widget_today_date, todayString)

            // 小组件刷新键，点击后由上方的onReceive接收，并触发此onUpdate方法
            val imageClickIntent = Intent(context, ScheduleWidgetProvider::class.java)
            imageClickIntent.action = "com.twt.appwidget.refresh"
            val imageClickPendingIntent = PendingIntent.getBroadcast(context, 0, imageClickIntent, PendingIntent.FLAG_UPDATE_CURRENT)
            remoteViews.setOnClickPendingIntent(R.id.widget_image_button, imageClickPendingIntent)

            // 小组件List部分，WidgetFactory的List为空则显示emptyView(也就是今日没课)
            val serviceIntent = Intent(context, WidgetService::class.java)
            serviceIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            serviceIntent.data = Uri.parse(serviceIntent.toUri(Intent.URI_INTENT_SCHEME))
            remoteViews.setRemoteAdapter(R.id.widget_listview, serviceIntent)
            remoteViews.setEmptyView(R.id.widget_listview, R.id.widget_empty_view)

            // List部分的点击监听，点击后跳转至Flutter课程表页
            val startActivityIntent = Intent(context, MainActivity::class.java)
            startActivityIntent.data = Uri.parse("${BASEURL}schedule")
            val startActivityPendingIntent = PendingIntent.getActivity(context, 0, startActivityIntent, PendingIntent.FLAG_UPDATE_CURRENT)
            remoteViews.setPendingIntentTemplate(R.id.widget_listview, startActivityPendingIntent)

            appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_listview)
            appWidgetManager.updateAppWidget(appWidgetId, remoteViews)
        }
        super.onUpdate(context, appWidgetManager, appWidgetIds)
    }

    private val todayString: String
        get() {
            val stringBuilder = StringBuilder()
            val time = Calendar.getInstance().time.let { dateFormat.format(it) }
            stringBuilder.append(time)
            stringBuilder.append("  ")
            val s = "星期" + getChineseCharacter()
            stringBuilder.append(s)
            return stringBuilder.toString()
        }

    private fun getChineseCharacter(): String {
        val today = Calendar.getInstance().get(Calendar.DAY_OF_WEEK)
        val cDay = arrayOf("零", "一", "二", "三", "四", "五", "六", "日")
        return if (today == Calendar.SUNDAY) cDay[7] else cDay[today - 1]
    }

    companion object {
        val dateFormat = SimpleDateFormat("yyyy/MM/dd", Locale.CHINA)
    }
}
