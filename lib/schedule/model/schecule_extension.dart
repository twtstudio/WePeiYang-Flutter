import 'package:flutter/material.dart';
import 'schedule_model.dart';

/// 生成一周内的日期，格式为 “MM/dd”，用0填充空位
/// [termStart] 本学期开始时间的时间戳
/// [week] 需要第几周的日期
/// [count] 需要6天还是7天的日期
List<String> getWeekDayString(int termStart, int week, int count) {
  var offset = 3600; // 加一个偏移量... 因为按照0点计算不保险
  var dayOfSeconds = 86400;
  // 每周开始的时间戳
  var startUnixWithOffset = termStart + offset + (week - 1) * dayOfSeconds * 7;
  List<String> list = [];
  for (var i = 0; i < count; i++) {
    // 选中周每天的date对象
    var date = DateTime.fromMillisecondsSinceEpoch(
        (startUnixWithOffset + dayOfSeconds * i) * 1000);
    // 用“0”填充日期的空位（比如: 8/5 -> 08/05）
    var month = date.month.toString();
    var formatMonth = month.length < 2 ? "0" + month : month;
    var day = date.day.toString();
    var formatDay = day.length < 2 ? "0" + day : day;
    list.add(formatMonth + '/' + formatDay);
  }
  return list;
}

// TODO
/// 为ActiveCourse生成随机颜色
Color generateColor() {
  return Colors.lightGreenAccent;
}

/// 为每周的点阵图生成bool矩阵
List<List<bool>> getBoolMatrix(int week, int weekCount, List<Course> courses) {
  List<List<bool>> list = [];
  for (var i = 0; i < 5; i++)
    list.add([false, false, false, false, false, false]);
  courses.forEach((course) {
    if (judgeIsActive(week, weekCount, course)) {
      var day = int.parse(course.arrange.day);
      var start = int.parse(course.arrange.start);
      var end = int.parse(course.arrange.end);
      for (var i = start; i <= end; i++)
        list[(i / 2).ceil() - 1][day - 1] = true;
    }
  });
  return list;
}

/// 判断当前周是否有此课
bool judgeIsActive(int week, int weekCount, Course course) =>
    getWeekStatus(weekCount, course)[week] == 1;

/// 该课程在所有周的状态  -1：没课  0：不上课  1：上课
/// （list是从下标1开始数的哦，所以list[3]对应的是第三周）
List<int> getWeekStatus(int weekCount, Course course) {
  List<int> list = [];

  /// 先默认所有周都没课（list[0]恒为-1）
  for (var i = 0; i <= weekCount; i++) list.add(-1);
  var start = int.parse(course.week.start);
  var end = int.parse(course.week.end);
  var remainder = 0;
  bool shouldMod = false;
  switch (course.arrange.week) {
    case "单周":
      remainder = 1;
      shouldMod = true;
      break;
    case "双周":
      remainder = 0;
      shouldMod = true;
      break;
  }

  /// 利用取模操作判断单双周
  for (var i = start; i <= end; i++) {
    if (shouldMod && (i % 2 != remainder))
      list[i] = 0;
    else
      list[i] = 1;
  }
  return list;
}
