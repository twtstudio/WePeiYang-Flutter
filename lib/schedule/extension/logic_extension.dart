import 'package:we_pei_yang_flutter/schedule/model/schedule_notifier.dart';
import 'package:we_pei_yang_flutter/schedule/model/school/school_model.dart';

/// 解决首页今日课程、课程表课程名称显示不全的问题（课程dialog不调用此函数）
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
  var dayOfSeconds = 86400;
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

/// 为每周的点阵图生成bool矩阵
List<List<bool>> getBoolMatrix(
    int week, int weekCount, List<ScheduleCourse> courses, bool showSevenDay) {
  List<List<bool>> list = [];
  for (var i = 0; i < 5; i++)
    list.add([false, false, false, false, false, false]);
  courses.forEach((course) {
    if (judgeActiveInWeek(week, weekCount, course)) {
      var day = int.parse(course.arrange.day);
      var start = int.parse(course.arrange.start);
      var end = int.parse(course.arrange.end);

      /// 课程占奇数节时忽略一小节（例: 5-7视为5-6），因为点阵图的每个点代表两小节课
      if ((end - start) % 2 == 0) end--;

      /// 第11~12小节展示不开了，故去除掉
      if (end > 10) end = 10;

      /// 判断周日的课是否需要显示在课表上
      if (showSevenDay || day != 7)
        for (var i = start; i <= end; i++)
          list[(i / 2).ceil() - 1][day - 1] = true;
    }
  });
  return list;
}

/// 返回每天合并冲突后的课程，[courses]是未经检验冲突的课程
/// 最外层List储存所有天的合并课（周一至周dayNumber）
/// 次外层List储存每一天的所有合并课
/// 最内层List储存单个合并课，[List.first]的课显示在外，同时用于冲突判断
List<List<List<ScheduleCourse>>> getMergedCourses(
    ScheduleNotifier notifier, int dayNumber) {
  List<ScheduleCourse> courses = notifier.coursesWithNotify;
  List<List<List<ScheduleCourse>>> result = [];
  for (int i = 0; i < dayNumber; i++) result.add([]);
  courses.forEach((course) {
    int day = int.parse(course.arrange.day);
    if (day > dayNumber) return; // 这里return起到continue的作用
    int start = int.parse(course.arrange.start);
    int end = int.parse(course.arrange.end);
    bool hasMerged = false;

    /// 对当天的所有的已合并课（List<ScheduleCourse>）遍历，若均未冲突则添加至当天
    result[day - 1].forEach((element) {
      int eStart = int.parse(element[0].arrange.start);
      int eEnd = int.parse(element[0].arrange.end);

      /// 判断当前课与List中的第一节课是否冲突
      if (checkMerged(course, element[0])) {
        hasMerged = true;

        /// List中只有一节inactive的课时，直接进行替换（这样List中的inactive课不会多于1节）
        if (element.length == 1 &&
            !judgeActiveInWeek(notifier.selectedWeekWithNotify,
                notifier.weekCount, element[0])) {
          element[0] = course;

          /// 若不满足上述，且当前课（course）为inactive时，直接return
        } else if (!judgeActiveInWeek(
            notifier.selectedWeekWithNotify, notifier.weekCount, course)) {
          return;

          /// 当前课时长较长，插入first处
        } else if ((end - start) > (eEnd - eStart)) {
          element.insert(0, course);

          /// List中第一节课时长较长，add即可
        } else if ((end - start) < (eEnd - eStart)) {
          element.add(course);

          /// 当前课较早，插入first处
        } else if (start < eStart) {
          element.insert(0, course);

          /// 当前课不比List第一节课早，add即可
        } else {
          element.add(course);
        }
      }
    });
    if (!hasMerged) result[day - 1].add([]..add(course));
  });
  return result;
}

/// 检查两节课是否时间冲突
bool checkMerged(ScheduleCourse c1, ScheduleCourse c2) {
  int start1 = int.parse(c1.arrange.start);
  int end1 = int.parse(c1.arrange.end);
  int start2 = int.parse(c2.arrange.start);
  int end2 = int.parse(c2.arrange.end);
  List<int> flag = List.filled(12, 0);
  for (int i = start1; i <= end1; i++) flag[i - 1]++;
  for (int i = start2; i <= end2; i++) flag[i - 1]++;
  return flag.contains(2);
}

/// 检查当前课程在选中周的状态
bool judgeActiveInWeek(int week, int weekCount, ScheduleCourse course) =>
    getWeekStatus(weekCount, course)[week];

/// 检查当天课程（day从1开始数）
bool judgeActiveInDay(
        int week, int day, int weekCount, ScheduleCourse course) =>
    int.parse(course.arrange.day) == day
        ? getWeekStatus(weekCount, course)[week]
        : false;

/// 检查明天课程（用于夜猫子模式）
bool judgeActiveTomorrow(
    int week, int day, int weekCount, ScheduleCourse course) {
  int offset = (day == 7) ? 1 : 0; // 如果今天是周日，则检查下一周的课程
  if (week + offset > weekCount) return false; // 如果后台一直不更新termStart, 这里有可能数组越界
  return (int.parse(course.arrange.day) == ((day + 1) % 7))
      ? getWeekStatus(weekCount, course)[week + offset]
      : false;
}

/// 该课程在所有周的状态
/// （list是从下标1开始数的哦，所以list[3]对应的是第三周）
List<bool> getWeekStatus(int weekCount, ScheduleCourse course) {
  List<bool> list = [];
  for (var i = 0; i <= weekCount; i++)
    list.add(course.arrange.binStr[i] == '1');
  return list;
}

/// 计算本学期已修学时（week为当前教学周，day从1开始数）
/// 注：依照此计算方法，只有当天结束时才会更改已修学时
int getCurrentHours(int week, int day, List<ScheduleCourse> courses) {
  int totalHour = 0;
  courses.forEach((course) {
    int weekCount = 0;
    for (int i = 1; i < week; i++)
      if (course.arrange.binStr[i] == '1') weekCount++;
    if (course.arrange.binStr[week] == "1" &&
        day > int.parse(course.arrange.day)) weekCount++;
    var arrangeStart = int.parse(course.arrange.start);
    var arrangeEnd = int.parse(course.arrange.end);
    totalHour += weekCount * (arrangeEnd - arrangeStart + 1);
  });
  return totalHour;
}

/// 计算本学期课程总学时
int getTotalHours(List<ScheduleCourse> courses) {
  int totalHour = 0;
  courses.forEach((course) {
    int weekCount = 0;
    for (int i = 1; i < course.arrange.binStr.length; i++)
      if (course.arrange.binStr[i] == '1') weekCount++;
    var arrangeStart = int.parse(course.arrange.start);
    var arrangeEnd = int.parse(course.arrange.end);
    totalHour += weekCount * (arrangeEnd - arrangeStart + 1);
  });
  return totalHour;
}

/// 去掉字符串中小括号里的内容：  张三（教授） -> 张三
String removeParentheses(String mode) =>
    mode.replaceAll(RegExp(r'\((.+?)\)'), '');

/// 去掉arrange对象的room属性中的 “楼”、“区” 等字眼
String replaceBuildingWord(String mode) =>
    mode.replaceAll('楼', '-').replaceAll('区', '');

String getCourseTime(String start, String end) {
  var startTimes = [
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
  var endTimes = [
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
  int s = int.parse(start);
  int e = int.parse(end);
  return "${startTimes[s - 1]}-${endTimes[e - 1]}";
}
