package com.twt.service.widget

import android.content.Context
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

fun readCourseList(context: Context): List<Course> {
    val courseList = mutableListOf<Course>()

    // 这里的name是flutter的shared_preferences源码中的, 下面的`flutter.`前缀也是
    val pref = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

    val nightMode = pref.getBoolean("flutter.nightMode", false) &&
            (Calendar.getInstance().get(Calendar.HOUR_OF_DAY) >= 21)

    // 用完整的目标日期处理夜猫子模式，包含跨周、跨月和跨年。
    val target = Calendar.getInstance().apply { if (nightMode) add(Calendar.DATE, 1) }
    val localFormat = SimpleDateFormat("yyyy-MM-dd", Locale.ROOT)
    val dateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.ROOT).apply {
        timeZone = TimeZone.getTimeZone("UTC")
        isLenient = false
    }
    val targetDate = dateFormat.parse(localFormat.format(target.time))!!
    val firstDay = Calendar.getInstance(TimeZone.getTimeZone("UTC")).apply {
        time = dateFormat.parse(localFormat.format(Date(
            pref.getLong("flutter.termStart", 1676822400) * 1000)))!!
        add(Calendar.DATE, -((get(Calendar.DAY_OF_WEEK) + 5) % 7))
    }.time
    fun weekOf(date: Date) = Math.floorDiv(date.time - firstDay.time, 604800000L).toInt() + 1
    fun weekdayOf(date: Date) = Calendar.getInstance(TimeZone.getTimeZone("UTC")).run {
        time = date
        (get(Calendar.DAY_OF_WEEK) + 5) % 7 + 1
    }
    val nowDay = weekdayOf(targetDate)
    val nowWeek = weekOf(targetDate)
    if (nowWeek !in 1..24) return courseList

    // 和 Flutter 使用同一份规则；调课只读来源日原课表，不追踪来源日规则。
    var schoolDate: Date? = targetDate
    runCatching {
        val rules = JSONObject(pref.getString("flutter.scheduleDayOverrides", "{}") ?: "{}")
        if (rules.optString("term") == pref.getString("flutter.termName", "22232") &&
            rules.optString("account") == pref.getString("flutter.tjuuname", "") &&
            rules.optString("termStart") == dateFormat.format(firstDay)) {
            val rule = rules.optJSONObject("days")?.optJSONObject(dateFormat.format(targetDate))
            when (rule?.optString("type")) {
                "off" -> schoolDate = null
                "replace" -> {
                    val text = rule.getString("sourceDate")
                    val source = dateFormat.parse(text)!!
                    if (dateFormat.format(source) == text && weekOf(source) in 1..24 && source != targetDate) {
                        schoolDate = source
                    }
                }
            }
        }
    }
    val schoolDay = schoolDate?.let { weekdayOf(it) }
    val schoolWeek = schoolDate?.let { weekOf(it) }

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
                val flag1 = schoolDay == arrange.getInt("weekday")
                val flag2 = arrange.getJSONArray("weekList").let { weekList ->
                    var flag = false
                    for( k in 0 until weekList.length()) {
                        if (weekList.getInt(k) == schoolWeek) flag = true
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
