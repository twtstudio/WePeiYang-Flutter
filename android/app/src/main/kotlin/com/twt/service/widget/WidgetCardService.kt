package com.twt.service.widget

import android.content.Intent
import android.widget.RemoteViewsService

class WidgetCardService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent?): RemoteViewsFactory {
        return WidgetCardFactory(this, readCourseList(this))
    }
}