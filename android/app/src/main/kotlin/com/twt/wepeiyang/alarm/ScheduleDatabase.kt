package com.twt.wepeiyang.alarm

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class ScheduleDatabase(
        context: Context?,
        name: String,
        factory: SQLiteDatabase.CursorFactory?,
        version: Int
) : SQLiteOpenHelper(context, name, factory, version) {
    private val scheduleData: String =
            """create table Schedule_data(
            |id integer primary key autoincrement, 
            |time long, 
            |name text)""".trimMargin()

    override fun onCreate(db: SQLiteDatabase?) {
        db?.execSQL(scheduleData)
    }

    override fun onUpgrade(db: SQLiteDatabase?, oldVersion: Int, newVersion: Int) {}
}