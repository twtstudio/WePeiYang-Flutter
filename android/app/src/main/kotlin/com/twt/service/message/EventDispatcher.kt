package com.twt.service.message

import android.content.Intent
import com.twt.service.WBYApplication
import com.twt.service.common.LogUtil
import com.twt.service.push.IntentEvent
import com.twt.service.push.model.Event

object EventDispatcher {
    private const val TAG = "EventDispatcher"
    private const val NO_EVENT_TYPE = -1
    private val shortcutEventTypes = setOf(
        IntentEvent.SchedulePage.type,
        IntentEvent.EntryQrPage.type,
    )

    fun enqueueShortcutIntent(intent: Intent?): Boolean {
        if (intent?.data?.host != "wpy.app") {
            LogUtil.d(TAG, "ignore shortcut intent action=${intent?.action} data=${intent?.dataString}")
            return false
        }

        val event = when (intent.data?.path) {
            "/schedule" -> Event(IntentEvent.SchedulePage.type, "go to schedule page without data")
            "/entryQr" -> Event(IntentEvent.EntryQrPage.type, "go to entry qr page")
            else -> return false
        }

        enqueueShortcutEvent(event)
        return true
    }

    fun nextEvent(): Event? = synchronized(WBYApplication.eventList) {
        val index = WBYApplication.eventList.indexOfFirst { it.type != NO_EVENT_TYPE }
        if (index == -1) return@synchronized null
        WBYApplication.eventList.removeAt(index)
    }

    fun enqueueEvent(event: Event, replaceTypes: Set<Int> = emptySet()) = synchronized(WBYApplication.eventList) {
        if (replaceTypes.isNotEmpty()) {
            WBYApplication.eventList.removeAll { it.type in replaceTypes }
        }
        WBYApplication.eventList.add(event)
        LogUtil.d(TAG, "enqueue event=$event eventList=${WBYApplication.eventList}")
        WbyMessagePlugin.notifyEventChanged()
    }

    private fun enqueueShortcutEvent(event: Event) = enqueueEvent(event, shortcutEventTypes)
}
