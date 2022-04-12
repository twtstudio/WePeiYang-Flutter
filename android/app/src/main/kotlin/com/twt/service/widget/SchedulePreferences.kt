package com.twt.service.widget

import android.content.Context
import org.json.JSONObject
import java.util.*
import kotlin.math.ceil
import kotlin.math.roundToInt

fun readCourseList(context: Context): List<Course> {
    val courseList = mutableListOf<Course>()

    // 这里的name是flutter的shared_preferences源码中的, 下面的`flutter.`前缀也是
    val pref = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

    val nightMode = pref.getBoolean("flutter.nightMode", false) &&
            (Calendar.getInstance().get(Calendar.HOUR_OF_DAY) >= 21)

    val day = Calendar.getInstance().get(Calendar.DAY_OF_WEEK)

    val nowDay = day.let {
        val today = if (it == Calendar.SUNDAY) 7 else it - 1
        if (nightMode) (today + 1) % 7 else today
    }
    val nowTime: Int = (Calendar.getInstance().timeInMillis / 1000).toInt()
    val termStart: Int = pref.getLong("flutter.termStart", 1645372800).toInt()
    val weeks: Double = (nowTime - termStart) / 604800.0

    val nowWeek = ceil(weeks).roundToInt().let {
        if (nightMode && day == Calendar.SUNDAY) it + 1 else it
    }

    // 假期里这个nowWeek可能为负或者超出周数上限，这里判断负数，超上限的判断在flag2那里
    if (nowWeek <= 0) return courseList

    pref.getString("flutter.courseData", "")?.let {
        if ("" == it) return emptyList()
        val obj = JSONObject(it)
        val schoolCourses = obj.getJSONArray("schoolCourses")
        for (i in 0 until schoolCourses.length()) {
            val scheduleCourse = schoolCourses.getJSONObject(i)
            var name = scheduleCourse.getString("name")
            if (name.length > 10) name = name.substring(0, 8) + "..."
            val arrangeList = scheduleCourse.getJSONArray("arrangeList")
            for (j in 0 until arrangeList.length()) {
                val arrange = arrangeList.getJSONObject(j)
                var location = arrange.getString("location").replace("-", "楼")
                if (location == "") location = "————"
                val unitList = arrange.getJSONArray("unitList")
                val time = getCourseTime(unitList.getInt(0), unitList.getInt(1))
                val flag1 = nowDay == arrange.getInt("weekday")
                val flag2 = arrange.getJSONArray("weekList").let { weekList ->
                    var flag = false
                    for( k in 0 until weekList.length()) {
                        if (weekList.getInt(k) == nowWeek) flag = true
                    }
                    flag
                }
                if (flag1 && flag2) courseList.add(Course(name, location, time))
            }
        }

        val customCourses = obj.getJSONArray("customCourses")
        for (i in 0 until customCourses.length()) {
            val customCourse = customCourses.getJSONObject(i)
            var name = customCourse.getString("name")
            if (name.length > 10) name = name.substring(0, 8) + "..."
            val arrangeList = customCourse.getJSONArray("arrangeList")
            for (j in 0 until arrangeList.length()) {
                val arrange = arrangeList.getJSONObject(j)
                var location = arrange.getString("location").replace("-", "楼")
                if (location == "") location = "————"
                val unitList = arrange.getJSONArray("unitList")
                val time = getCourseTime(unitList.getInt(0), unitList.getInt(1))
                val flag1 = nowDay == arrange.getInt("weekday")
                val flag2 = arrange.getJSONArray("weekList").let { weekList ->
                    var flag = false
                    for( k in 0 until weekList.length()) {
                        if (weekList.getInt(k) == nowWeek) flag = true
                    }
                    flag
                }
                if (flag1 && flag2) courseList.add(Course(name, location, time))
            }
        }
    }
    courseList.sortWith { a, b -> a.time.compareTo(b.time) }
    return courseList
}

private fun getCourseTime(start: Int, end: Int): String {
    val startTimes = arrayListOf("08:30",
            "09:20",
            "10:25",
            "11:15",
            "13:30",
            "14:20",
            "15:25",
            "16:15",
            "18:30",
            "19:20",
            "20:10",
            "21:00")

    val endTimes = arrayListOf("09:15",
            "10:05",
            "11:10",
            "12:00",
            "14:15",
            "15:05",
            "16:10",
            "17:00",
            "19:15",
            "20:05",
            "20:55",
            "21:45")

    return "${startTimes[start - 1]}-${endTimes[end - 1]}"
}

class Course(val courseName: String = "", val room: String = "", val time: String = "")