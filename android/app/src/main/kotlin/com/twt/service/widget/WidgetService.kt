package com.twt.service.widget

import android.content.Intent
import android.util.Log
import android.widget.RemoteViewsService

class WidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent?): RemoteViewsFactory {
        Log.d("WBY", "widget service!!!!!")
        return WidgetFactory(this, readCourseList(this))
    }
}