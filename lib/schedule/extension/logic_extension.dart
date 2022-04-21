// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/model/course_provider.dart';

/// 为每周的点阵图生成bool矩阵
List<List<bool>> getBoolMatrix(int week, int weekCount, List<Course> courses) {
  var dayNumber = CommonPreferences.dayNumber.value;
  // 这里不能 `list = List.filled(5, List.filled(6, false))` 这么写，不然外层List中会是同一个引用对象
  List<List<bool>> list = [];
  for (int i = 0; i < 5; i++) list.add(List.filled(dayNumber, false));
  courses.forEach((course) {
    course.arrangeList.forEach((arrange) {
      if (judgeActiveInWeek(week, weekCount, arrange)) {
        var day = arrange.weekday;
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

/// 获取合并后的*非本周*课程，每小节课最多一节课程（即没有重叠）
/// 先按普通课程优先排序，再按高学分优先排序
List<Pair<Course, int>> getMergedInactiveCourses(
    CourseProvider provider, int dayNumber) {
  List<Course> courses = provider.totalCourses;
  courses.sort((a, b) {
    // 普通课程优先
    if (a.type == 1) return 1;
    if (b.type == 1) return -1;

    // 学分高优先，null(或不能解析成double的值)排最后
    double? iA = double.tryParse(a.credit);
    double? iB = double.tryParse(b.credit);
    if (iA == null) return 1;
    if (iB == null) return -1;
    return iB.compareTo(iA);
  });
  List<List<bool>> matrix = [];
  List<Pair<Course, int>> result = [];
  for (int i = 0; i < dayNumber; i++) matrix.add(List.filled(12, false));
  courses.forEach((course) {
    for (int index = 0; index < course.arrangeList.length; index++) {
      var arrange = course.arrangeList[index];
      if (judgeActiveInWeek(provider.selectedWeek, provider.weekCount, arrange))
        return;
      bool flag = false;
      for (int i = arrange.unitList.first; i <= arrange.unitList.last; i++) {
        if (matrix[arrange.weekday - 1][i]) {
          flag = true;
          break;
        }
      }
      if (flag) return;
      for (int i = arrange.unitList.first; i <= arrange.unitList.last; i++) {
        matrix[arrange.weekday - 1][i] = true;
      }
      result.add(Pair<Course, int>(course, index));
    }
  });
  return result;
}

/// 获取合并后的*本周*课程
/// List<List<Pair<Course, int>>> 存储所有冲突课程，每个子List的第一个课程外显，其他位置的课程均与List[0]冲突
List<List<Pair<Course, int>>> getMergedActiveCourses(
    CourseProvider provider, int dayNumber) {
  // 整理出所有本周arrange
  List<Pair<Course, int>> pairList = [];
  // 先添加普通课程
  provider.schoolCourses.forEach((course) {
    for (int j = 0; j < course.arrangeList.length; j++) {
      if (judgeActiveInWeek(
          provider.selectedWeek, provider.weekCount, course.arrangeList[j])) {
        pairList.add(Pair<Course, int>(course, j));
      }
    }
  });
  // 再添加自定义课程
  for (int i = 0; i < provider.customCourses.length; i++) {
    var course = provider.customCourses[i];
    course.index = null; // 这里很坑，需要重置状态
    course.needFloat = null;
    for (int j = 0; j < course.arrangeList.length; j++) {
      if (judgeActiveInWeek(
          provider.selectedWeek, provider.weekCount, course.arrangeList[j])) {
        course.index = i;
        pairList.add(Pair<Course, int>(course, j));
      }
    }
  }
  // 按照普通课程优先、短课程优先、时间早优先、高学分优先来排序
  pairList.sort((a, b) {
    // 普通课程优先
    if (a.first.type == 1 && b.first.type == 0) return 1;
    if (a.first.type == 0 && b.first.type == 1) return -1;

    // 短课程优先
    var aFirst = a.arrange.unitList.first;
    var aLast = a.arrange.unitList.last;
    var bFirst = b.arrange.unitList.first;
    var bLast = b.arrange.unitList.last;
    var aLen = aLast - aFirst;
    var bLen = bLast - bFirst;
    if (aLen != bLen) return aLen.compareTo(bLen);

    // 时间早优先
    if (aFirst != bFirst) return aFirst.compareTo(bFirst);

    // 学分高优先，null(或不能解析成double的值)排最后
    double? iA = double.tryParse(a.first.credit);
    double? iB = double.tryParse(b.first.credit);
    if (iA == null) return 1;
    if (iB == null) return -1;
    return iB.compareTo(iA);
  });
  // 每个子List为一组冲突课程：List[0]显示在外，其他位置的课程均与List[0]冲突
  List<List<Pair<Course, int>>> mergedList = [];
  // 不显示在外的课程
  List<Pair<Course, int>> notAppendList = [];
  // 二维矩阵，记录每个位置的课程量，显示在外的不能超过两节
  List<List<int>> unitCountMatrix = [];
  for (int i = 0; i < dayNumber; i++) {
    unitCountMatrix.add(List.filled(12, 0));
  }

  pairList.forEach((pair) {
    var start = pair.arrange.unitList.first;
    var end = pair.arrange.unitList.last;
    var day = pair.arrange.weekday - 1;
    var needAppend = true; // `pair`是否需要外显
    for (int i = start; i <= end; i++) {
      if (unitCountMatrix[day][i - 1] == 2) {
        needAppend = false; // 如果某位置已经有了两节课，`pair`不能外显
        break;
      }
    }
    // 存储与`pair`相互冲突的课程
    List<Pair<Course, int>> conflictList = [pair];
    // 和所有外显课程判断冲突
    for (int i = 0; i < mergedList.length; i++) {
      var status = _checkMerged(pair.arrange, mergedList[i][0].arrange);
      switch (status) {
        case 2: // 如果完全重叠，标记该外显课程需要“漂浮”显示
          if (needAppend) mergedList[i][0].first.needFloat = true;
          continue c1;
        c1:
        case 1: // 如果存在重叠，互相添加至冲突列表中
          mergedList[i].add(pair);
          conflictList.add(mergedList[i][0]);
      }
    }
    // 和所有非外显课程判断冲突
    notAppendList.forEach((notAppend) {
      if (_checkMerged(pair.arrange, notAppend.arrange) != 0) {
        conflictList.add(notAppend); // 如果存在重叠，添加至`pair`的冲突列表中
      }
    });

    if (needAppend) {
      mergedList.add(conflictList);
      for (int i = start; i <= end; i++) unitCountMatrix[day][i - 1]++;
    } else {
      notAppendList.add(pair);
    }
  });

  return mergedList;
}

/// 检查两节课是否时间冲突，0->不冲突，1->部分重叠，2->完全重叠
int _checkMerged(Arrange a1, Arrange a2) {
  if (a1.weekday != a2.weekday) return 0;
  int start1 = a1.unitList.first;
  int end1 = a1.unitList.last;
  int start2 = a2.unitList.first;
  int end2 = a2.unitList.last;
  if (end1 < start2 || end2 < start1) return 0;
  if (start1 == start2 && end1 == end2) return 2;
  return 1;
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
