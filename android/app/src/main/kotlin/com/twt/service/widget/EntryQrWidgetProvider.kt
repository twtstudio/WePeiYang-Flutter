package com.twt.service.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import com.twt.service.MainActivity
import com.twt.service.R
import com.twt.service.common.LogUtil
import com.twt.service.push.BASEURL
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class EntryQrWidgetProvider : AppWidgetProvider() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == ACTION_REFRESH) {
            refreshAll(context.applicationContext)
            return
        }
        super.onReceive(context, intent)
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (appWidgetId in appWidgetIds) {
            appWidgetManager.updateAppWidget(
                appWidgetId,
                createLoadingViews(context, "点击刷新获取二维码"),
            )
        }
        refreshAll(context.applicationContext)
    }

    companion object {
        const val ACTION_REFRESH = "com.twt.entry_qr_widget.refresh"
        private const val TAG = "ENTRY_QR_WIDGET"
        private val timeFormat = SimpleDateFormat("MM-dd HH:mm:ss", Locale.CHINA)

        fun refreshAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val componentName = ComponentName(context, EntryQrWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(componentName)
            if (ids.isEmpty()) return

            ids.forEach { id ->
                manager.updateAppWidget(id, createLoadingViews(context, "正在刷新..."))
            }

            CoroutineScope(Dispatchers.IO).launch {
                try {
                    val sid = EntryQrService.readSid(context)
                    Log.d(TAG, "SID: ${sid.take(3)}***")
                    val content = EntryQrService.fetchQrContent(sid)
                    Log.d(TAG, "QR content length: ${content.length}")
                    val bitmap = EntryQrService.createQrBitmap(content)
                    Log.d(TAG, "QR bitmap created: ${bitmap.width}x${bitmap.height}")
                    withContext(Dispatchers.Main) {
                        val timeText = "更新于 ${timeFormat.format(Date())}"
                        ids.forEach { id ->
                            manager.updateAppWidget(id, createContentViews(context, bitmap, timeText))
                        }
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "refresh failed", e)
                    withContext(Dispatchers.Main) {
                        ids.forEach { id ->
                            manager.updateAppWidget(
                                id,
                                createLoadingViews(context, e.message ?: "刷新失败"),
                            )
                        }
                    }
                }
            }
        }

        private fun createContentViews(
            context: Context,
            bitmap: android.graphics.Bitmap,
            timeText: String,
        ): RemoteViews {
            return baseViews(context).apply {
                setViewVisibility(R.id.entry_qr_widget_hint, View.GONE)
                setViewVisibility(R.id.entry_qr_widget_image, View.VISIBLE)
                setImageViewBitmap(R.id.entry_qr_widget_image, bitmap)
                setTextViewText(R.id.entry_qr_widget_time, timeText)
            }
        }

        private fun createLoadingViews(context: Context, hint: String): RemoteViews {
            return baseViews(context).apply {
                setViewVisibility(R.id.entry_qr_widget_hint, View.VISIBLE)
                setViewVisibility(R.id.entry_qr_widget_image, View.GONE)
                setTextViewText(R.id.entry_qr_widget_hint, hint)
                setTextViewText(R.id.entry_qr_widget_time, "二维码 3 分钟有效")
            }
        }

        private fun baseViews(context: Context): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.widget_entry_qr_card)
            views.setOnClickPendingIntent(R.id.entry_qr_widget_root, openEntryQrPendingIntent(context))
            views.setOnClickPendingIntent(R.id.entry_qr_widget_refresh, refreshPendingIntent(context))
            views.setOnClickPendingIntent(R.id.entry_qr_widget_image, refreshPendingIntent(context))
            return views
        }

        private fun openEntryQrPendingIntent(context: Context): PendingIntent {
            val intent = Intent(context, MainActivity::class.java).apply {
                data = Uri.parse("${BASEURL}entryQr")
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }
            return PendingIntent.getActivity(
                context,
                2101,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }

        private fun refreshPendingIntent(context: Context): PendingIntent {
            val intent = Intent(context, EntryQrWidgetProvider::class.java).apply {
                action = ACTION_REFRESH
            }
            return PendingIntent.getBroadcast(
                context,
                2102,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }
    }
}
