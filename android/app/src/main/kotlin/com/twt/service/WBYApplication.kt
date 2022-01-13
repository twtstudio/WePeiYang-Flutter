package com.twt.service

import android.content.Context
import com.twt.service.push.model.Event
import io.flutter.app.FlutterApplication
import java.lang.ref.WeakReference

class WBYApplication : FlutterApplication() {
    companion object {
        var context: WeakReference<Context>? = null
        var eventList = mutableListOf<Event>().apply { add(Event(-1, "null")) }
    }

    override fun onCreate() {
        super.onCreate()
        context = WeakReference(applicationContext)
    }
}