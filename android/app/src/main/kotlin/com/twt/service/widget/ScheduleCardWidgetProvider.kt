package com.twt.service.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import com.twt.service.MainActivity
import com.twt.service.R
import com.twt.service.push.BASEURL
import com.twt.service.common.LogUtil
import java.util.*

class ScheduleCardWidgetProvider : AppWidgetProvider() {
    override fun onEnabled(context: Context?) {
        super.onEnabled(context)
        log("课程表小部件_card被启用")
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE || intent.action == "com.twt.appwidget.refresh") {
            log("on refreshing!!!")
            val name = ComponentName(context, ScheduleCardWidgetProvider::class.java)
            this@ScheduleCardWidgetProvider.onUpdate(context, AppWidgetManager.getInstance(context), AppWidgetManager.getInstance(context).getAppWidgetIds(name))
        }
        super.onReceive(context, intent)
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        log("on updating!!!")
        for (appWidgetId in appWidgetIds) {
            // 小组件整体的点击监听，点击后跳转至MainActivity
            val startActivityIntent = Intent(context, MainActivity::class.java)
            startActivityIntent.data = Uri.parse("${BASEURL}schedule")
            val pendingIntent = PendingIntent.getActivity(context, 0, startActivityIntent, PendingIntent.FLAG_IMMUTABLE)
            val remoteViews = RemoteViews(context.packageName, R.layout.widget_schedule_card)
            remoteViews.setOnClickPendingIntent(R.id.fragment_card_view, pendingIntent)

            // 小组件周图片
            remoteViews.setImageViewResource(R.id.widget_week, getWeek())

            // 这是啥？
            // 小组件List部分，WidgetFactory的List为空则显示emptyView(也就是今日没课)
            val serviceIntent = Intent(context, WidgetCardService::class.java)
            serviceIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            serviceIntent.data = Uri.parse(serviceIntent.toUri(Intent.URI_INTENT_SCHEME))
            remoteViews.setRemoteAdapter(R.id.widget_listview_card, serviceIntent)
            remoteViews.setEmptyView(R.id.widget_listview_card, getEmptyView())

            // List部分的点击监听，点击后跳转至Flutter课程表页
            val startActivityPendingIntent = PendingIntent.getActivity(context, 0, startActivityIntent, PendingIntent.FLAG_IMMUTABLE)
            remoteViews.setPendingIntentTemplate(R.id.widget_listview_card, startActivityPendingIntent)
            appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_listview_card)
            appWidgetManager.updateAppWidget(appWidgetId, remoteViews)
        }
        super.onUpdate(context, appWidgetManager, appWidgetIds)
    }

    private fun getEmptyView(): Int {
        val now = Calendar.HOUR
        return if (now in 6..18) R.id.widget_empty_view_day else R.id.widget_empty_view_night
    }

    private fun getWeek(): Int {
        val today = Calendar.getInstance().get(Calendar.DAY_OF_WEEK)
        val cDay = arrayOf(R.drawable.sunday, R.drawable.monday, R.drawable.tuesday, R.drawable.wednesday, R.drawable.thursday, R.drawable.friday, R.drawable.saturday, R.drawable.sunday)
        return if (today == Calendar.SUNDAY) cDay[7] else cDay[today - 1]
    }

    companion object {
        const val TAG = "WBY-card"
        fun log(message: String) = LogUtil.d(TAG, message)
    }
}