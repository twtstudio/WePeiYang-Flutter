import 'school/common_model.dart';

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

/// 为每周的点阵图生成bool矩阵
List<List<bool>> getBoolMatrix(
    int week, int weekCount, List<Course> courses, bool showSevenDay) {
  List<List<bool>> list = [];
  for (var i = 0; i < 5; i++)
    list.add([false, false, false, false, false, false]);
  courses.forEach((course) {
    if (judgeIsActive(week, weekCount, course)) {
      var day = int.parse(course.arrange.day);
      var start = int.parse(course.arrange.start);
      var end = int.parse(course.arrange.end);

      /// 课程占奇数节时忽略一小节（例: 5-7视为5-6），因为点阵图的每个点代表两小节课
      if ((end - start) % 2 == 0) end--;

      /// 判断周日的课是否需要显示在课表上
      if (showSevenDay || day != 7)
        for (var i = start; i <= end; i++)
          list[(i / 2).ceil() - 1][day - 1] = true;
    }
  });
  return list;
}

/// 检查当前课程在选中周的状态
bool judgeIsActive(int week, int weekCount, Course course) =>
    getWeekStatus(weekCount, course)[week];

/// 该课程在所有周的状态
/// （list是从下标1开始数的哦，所以list[3]对应的是第三周）
List<bool> getWeekStatus(int weekCount, Course course) {
  List<bool> list = [];

  /// 先默认所有周都没课（list[0]恒为false,反正也用不上）
  for (var i = 0; i <= weekCount; i++) list.add(false);
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

  /// 利用取模操作判断是否有课
  for (var i = start; i <= end; i++)
    if (!shouldMod || (i % 2 == remainder)) list[i] = true;
  return list;
}

/// 去掉字符串中小括号里的内容：  张三（教授） -> 张三
String removeParentheses(String mode) =>
    mode.replaceAll(RegExp(r'\((.+?)\)'), '');

/// 去掉arrange对象的room属性中的 “楼”、“区” 等字眼
String replaceBuildingWord(String mode) =>
    mode.replaceAll(RegExp('楼'), '-').replaceAll('区', '');

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
