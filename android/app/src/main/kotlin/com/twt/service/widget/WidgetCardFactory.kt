package com.twt.service.widget

import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import com.twt.service.R

class WidgetCardFactory(var mContext: Context, var courseList: List<Course>) : RemoteViewsService.RemoteViewsFactory {
    override fun getViewAt(position: Int): RemoteViews {
        val remoteViewsCard = RemoteViews(mContext.packageName, R.layout.widget_schedule_card_item)
        val course = courseList[position]
        remoteViewsCard.setTextViewText(R.id.class_id, course.courseName)
        remoteViewsCard.setTextViewText(R.id.room_id, course.room)
        remoteViewsCard.setTextViewText(R.id.time_id, course.time)
        remoteViewsCard.setOnClickFillInIntent(R.id.widget_schedule_card_item, Intent())
        return remoteViewsCard
    }

    override fun onCreate() {
    }

    override fun onDataSetChanged() {
        courseList = readCourseList(mContext)
    }

    override fun onDestroy() {
        courseList = emptyList()
    }

    override fun getCount(): Int = courseList.size

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long = position.toLong()

    override fun hasStableIds(): Boolean = false
}
