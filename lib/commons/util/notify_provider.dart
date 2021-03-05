import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/schedule/model/schedule_notifier.dart';

import '../../main.dart';

class NotifyProvider {
  // TODO 提醒功能的数据没问题了，提醒功能本身有点抽风，在修了
  static final _notificationBar =
      const MethodChannel('com.example.wei_pei_yang_demo/notify');

  static Future<void> startNotification() async => null;
      // await _notificationBar.invokeMethod('setStatus', {'bool': true});

  static Future<void> stopNotification() async => null;
      // await _notificationBar.invokeMethod('setStatus', {'bool': false});

  static Future<void> setNotificationData() async {
    return null;
    List<Map<String, dynamic>> data = List();
    var offset = 3600; // 比较当天课程时加一个小时的偏移量... 这样保险一些
    var dayOfSeconds = 86400;
    var weekOfSeconds = 604800;
    var remindTime = CommonPreferences().remindTime.value; // second
    var notifier = Provider.of<ScheduleNotifier>(
        WeiPeiYangApp.navigatorState.currentContext,
        listen: false);
    var courses = notifier.coursesWithNotify;
    var currentWeek = notifier.currentWeekWithNotify;
    var today = DateTime.now().weekday;
    var termStart = notifier.termStart;
    courses.forEach((course) {
      int startWeek = int.parse(course.week.start);
      int endWeek = int.parse(course.week.end);
      if (startWeek <= currentWeek && currentWeek <= endWeek) {
        int day = int.parse(course.arrange.day);
        int start = int.parse(course.arrange.start); // 既然是开课前提醒，就只需要关心start即可
        int weekOffset = 0, weekStep = 1;
        switch (course.arrange.week) {
          case "单周":
            weekStep = 2;
            if (currentWeek.isEven) weekOffset = 1;
            break;
          case "双周":
            weekStep = 2;
            if (currentWeek.isOdd) weekOffset = 1;
            break;
        }
        for (int i = currentWeek + weekOffset; i <= endWeek; i += weekStep) {
          if (i == currentWeek && today > day) continue;
          if (i == currentWeek && today == day) {
            var now = DateTime.now();
            var todaySecond = now.hour * 3600 + now.minute * 60 + now.second;
            if (todaySecond + offset >= _secondByArrangeStart(start)) continue;
          }
          var time = termStart +
              (i - 1) * weekOfSeconds +
              (day - 1) * dayOfSeconds +
              _secondByArrangeStart(start) -
              remindTime;
          data.add({'name': course.courseName, 'time': time});
        }
      }
    });
    print(data);
    await _notificationBar.invokeMethod('setData', {'list': data});
  }

  static int _secondByArrangeStart(int start) => [
        30600,
        33600,
        37500,
        40500,
        48600,
        51600,
        55500,
        58500,
        66600,
        69600,
        72600,
        75600
      ][start - 1];
}
