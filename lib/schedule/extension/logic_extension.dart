// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';

/// 为每周的点阵图生成bool矩阵
List<List<bool>> getBoolMatrix(int week, int weekCount, List<Course> courses) {
  // 这里不能 `list = List.filled(5, List.filled(6, false))` 这么写，不然外层List中会是同一个引用对象
  List<List<bool>> list = [];
  for (int i = 0; i < 5; i++) list.add(List.filled(6, false));
  courses.forEach((course) {
    course.arrangeList.forEach((arrange) {
      if (judgeActiveInWeek(week, weekCount, arrange)) {
        var day = arrange.weekday;
        if (day == 7) return; // 忽略周日
        var start = arrange.unitList.first;
        var end = arrange.unitList.last;

        /// 课程占奇数节时忽略一小节（例: 5-7视为5-6），因为点阵图的每个点代表两小节课
        if ((end - start) % 2 == 0) end--;

        /// 第11~12小节展示不开了，故去除掉
        if (end > 10) end = 10;

        for (var i = start; i <= end; i++) {
          list[(i / 2).ceil() - 1][day - 1] = true;
        }
      }
    });
  });
  return list;
}

/// 返回每天合并冲突后的课程，[courses]是未经检验冲突的课程
/// 最外层List储存所有天的合并课（周一至周dayNumber）
/// 次外层List储存每一天的所有合并课
/// 最内层List储存合并课，合并课由许多[Pair]组成，其通过下标指出了某个[Course]的某个[Arrange]
/// [List.first]的课显示在外，同时用于冲突判断
List<List<List<Pair<Course, int>>>> getMergedCourses(
    CourseProvider provider, int dayNumber) {
  List<Course> courses = provider.courses;
  List<List<List<Pair<Course, int>>>> result = [];
  for (int i = 0; i < dayNumber; i++) result.add([]);
  courses.forEach((course) {
    for (int i = 0; i < course.arrangeList.length; i++) {
      /// 当前需要判断的课程
      var current = Pair<Course, int>(course, i);
      int day = current.arrange.weekday;
      if (day > dayNumber) return; // 这里return起到continue的作用
      int start = current.arrange.unitList.first;
      int end = current.arrange.unitList.last;
      bool hasMerged = false;

      /// 对当天的所有的已合并课（List<Pair<Course, int>>）遍历，若均未冲突则添加至当天
      result[day - 1].forEach((pairList) {
        int eStart = pairList[0].arrange.unitList.first;
        int eEnd = pairList[0].arrange.unitList.last;

        /// 判断当前课与List中的第一节课是否冲突
        if (_checkMerged(current.arrange, pairList[0].arrange)) {
          hasMerged = true;

          /// List中只有一节inactive的课时，直接进行替换（这样List中的inactive课不会多于1节）
          if (pairList.length == 1 &&
              !judgeActiveInWeek(provider.selectedWeek, provider.weekCount,
                  pairList[0].arrange)) {
            pairList[0] = current;

            /// 若不满足上述，且当前课为inactive时，直接return
          } else if (!judgeActiveInWeek(
              provider.selectedWeek, provider.weekCount, current.arrange)) {
            return;

            /// 当前课时长较长，插入first处
          } else if ((end - start) > (eEnd - eStart)) {
            pairList.insert(0, current);

            /// List中第一节课时长较长，add即可
          } else if ((end - start) < (eEnd - eStart)) {
            pairList.add(current);

            /// 当前课较早，插入first处
          } else if (start < eStart) {
            pairList.insert(0, current);

            /// 当前课不比List第一节课早，add即可
          } else {
            pairList.add(current);
          }
        }
      });
      if (!hasMerged) result[day - 1].add([current]);
    }
  });
  return result;
}

/// 检查两节课是否时间冲突
bool _checkMerged(Arrange a1, Arrange a2) {
  int start1 = a1.unitList.first;
  int end1 = a1.unitList.last;
  int start2 = a2.unitList.first;
  int end2 = a2.unitList.last;
  List<int> flag = List.filled(12, 0);
  for (int i = start1; i <= end1; i++) flag[i - 1]++;
  for (int i = start2; i <= end2; i++) flag[i - 1]++;
  return flag.contains(2);
}

/// 检查当前课程在选中周的状态
bool judgeActiveInWeek(int week, int weekCount, Arrange arrange) =>
    _getWeekStatus(weekCount, arrange)[week];

/// 检查当天课程（day从1开始数）
bool judgeActiveInDay(int week, int day, int weekCount, Arrange arrange) =>
    arrange.weekday == day ? _getWeekStatus(weekCount, arrange)[week] : false;

/// 检查明天课程（用于夜猫子模式）
bool judgeActiveTomorrow(int week, int day, int weekCount, Arrange arrange) {
  int offset = (day == 7) ? 1 : 0; // 如果今天是周日，则检查下一周的课程
  if (week + offset > weekCount) return false; // 防止数组越界
  return (arrange.weekday == ((day + 1) % 7))
      ? _getWeekStatus(weekCount, arrange)[week + offset]
      : false;
}

/// 该课程在所有周的状态
/// （list是从下标1开始数的哦，所以list[3]对应的是第三周）
List<bool> _getWeekStatus(int weekCount, Arrange arrange) {
  List<bool> list = [];
  for (var i = 0; i <= weekCount; i++) {
    list.add(arrange.weekList.contains(i));
  }
  return list;
}

/// 是否已开学
bool get isBeforeTermStart =>
    DateTime.now().millisecondsSinceEpoch / 1000 <
    CommonPreferences.termStart.value;

/// 夜猫子模式下，是否已开学，86400代表一天
bool get isOneDayBeforeTermStart =>
    (DateTime.now().millisecondsSinceEpoch / 1000 + 86400) <
    CommonPreferences.termStart.value;

/// 计算本学期已修学时（week为当前教学周，day从1开始数）
/// 注：依照此计算方法，只有当天结束时才会更改已修学时
int getCurrentHours(int week, int day, List<Course> courses) {
  int totalHour = 0;
  courses.forEach((course) {
    course.arrangeList.forEach((arrange) {
      int weekCount = 0;
      for (int i = 1; i < week; i++) {
        if (arrange.weekList.contains(i)) weekCount++;
      }
      if (arrange.weekList.contains(week) && day > arrange.weekday) {
        weekCount++;
      }
      var arrangeStart = arrange.unitList.first;
      var arrangeEnd = arrange.unitList.last;
      totalHour += weekCount * (arrangeEnd - arrangeStart + 1);
    });
  });
  return totalHour;
}

/// 计算本学期课程总学时
int getTotalHours(List<Course> courses) {
  int totalHour = 0;
  courses.forEach((course) {
    course.arrangeList.forEach((arrange) {
      int weekCount = arrange.weekList.length;
      var arrangeStart = arrange.unitList.first;
      var arrangeEnd = arrange.unitList.last;
      totalHour += weekCount * (arrangeEnd - arrangeStart + 1);
    });
  });
  return totalHour;
}

final _today = DateTime.now().day;

/// 根据课程名生成对应颜色
Color generateColor(String courseName) {
  int hashCode = courseName.hashCode + _today; // 加点随机元素，以防一学期都是一个颜色
  return FavorColors.scheduleColor[hashCode % FavorColors.scheduleColor.length];
}

/// 防止首页今日课程、课程表课程名称过长
String formatText(String text) {
  if (text.length > 13)
    return text.substring(0, 13) + "...";
  else
    return text;
}

/// 生成一周内的日期，格式为 “MM/dd”，用0填充空位
/// [termStart] 本学期开始时间的时间戳
/// [week] 需要第几周的日期
/// [count] 需要6天还是7天的日期
List<String> getWeekDayString(int termStart, int week, int count) {
  const dayOfSeconds = 86400;
  // 每周开始的时间戳
  var startUnixWithOffset = termStart + (week - 1) * dayOfSeconds * 7;
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

/// 去掉字符串中小括号里的内容：  张三（教授） -> 张三
String removeParentheses(String mode) =>
    mode.replaceAll(RegExp(r'\((.+?)\)'), '');

/// 去掉arrange对象的room属性中的 “楼”、“区” 等字眼
String replaceBuildingWord(String mode) =>
    mode.replaceAll('楼', '-').replaceAll('区', '');

String getCourseTime(List<int> unit) =>
    "${_startTimes[unit.first - 1]}-${_endTimes[unit.last - 1]}";

const _startTimes = [
  '08:30',
  '09:20',
  '10:25',
  '11:15',
  '13:30',
  '14:20',
  '15:25',
  '16:15',
  '18:30',
  '19:20',
  '20:10',
  '21:00'
];

const _endTimes = [
  '09:15',
  '10:05',
  '11:10',
  '12:00',
  '14:15',
  '15:05',
  '16:10',
  '17:00',
  '19:15',
  '20:05',
  '20:55',
  '21:45'
];
