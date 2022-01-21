package com.twt.service.widget

import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import com.twt.service.R

class WidgetFactory(var mContext: Context, var courseList: List<Course>) : RemoteViewsService.RemoteViewsFactory {
    override fun getViewAt(position: Int): RemoteViews {
        val remoteViews = RemoteViews(mContext.packageName, R.layout.widget_schedule_item)
        val course = courseList[position]
        remoteViews.setTextViewText(R.id.widget_course_title, course.courseName)
        remoteViews.setTextViewText(R.id.widget_course_location, course.room)
        remoteViews.setTextViewText(R.id.widget_course_time, course.time)
        
        remoteViews.setOnClickFillInIntent(R.id.widget_schedule_item, Intent())
        
        return remoteViews
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

