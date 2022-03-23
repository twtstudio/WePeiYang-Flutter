// @dart = 2.12

import 'package:we_pei_yang_flutter/commons/environment/config.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';

class Time {
  static const monday = 'Monday';
  static const tuesday = 'Tuesday';
  static const wednesday = 'Wednesday';
  static const thursday = 'Thursday';
  static const friday = 'Friday';
  static const saturday = 'Saturday';
  static const sunday = 'Sunday';

  static const List<String> week = [
    monday,
    tuesday,
    wednesday,
    thursday,
    friday,
    saturday,
    sunday,
  ];

  static DateTime semesterStart() {
    var firstDay = DateTime.tryParse(CommonPreferences().termStartDate.value);
    if (firstDay != null) {
      // 防止错误
      return firstDay.next.weekStart;
    } else {
      // 想想办法
      if (EnvConfig.isDevelop) {
        throw Exception('can not get semester start time');
      }
      return DateTime(2021, 8, 16);
    }
  }

  static bool availableNow(String state, List<ClassTime> schedules) =>
      state.isNotEmpty && schedules.isNotEmpty
          ? schedules.map((time) {
              var list = state.split('');
              if (list[time.id * 2 - 1] == '0' &&
                  list[time.id * 2 - 2] == '0') {
                return true;
              } else {
                return false;
              }
            }).reduce((v, e) => v && e)
          : !state.contains('1');

  static Current classOfDay(DateTime date) {
    var h = date.hour;
    if (h < 10) {
      return Current(date, ClassTime.am_1);
    } else if (h < 12) {
      return Current(date, ClassTime.am_2);
    } else if (h < 15) {
      return Current(date, ClassTime.pm_1);
    } else if (h < 17) {
      return Current(date, ClassTime.pm_2);
    } else if (h < 20) {
      return Current(date, ClassTime.pm_3);
    } else if (h < 22) {
      return Current(date, ClassTime.pm_4);
    } else {
      // 晚上十点以后显示第二天早上第一节课
      return Current(date.next, ClassTime.am_1);
    }
  }

  static DateTime checkDateTimeAvailable(DateTime dateTime) {
    if (dateTime.isBefore(Time.semesterStart())) {
      return Time.semesterStart();
    }
    return dateTime;
  }

  static List<ClassTime> get rangeList => [
        ClassTime.am_1,
        ClassTime.am_2,
        ClassTime.pm_1,
        ClassTime.pm_2,
        ClassTime.pm_3,
        ClassTime.pm_4
      ];
}

class Current {
  final DateTime date;
  final ClassTime classTime;

  Current(this.date, this.classTime);
}

enum ClassTime { am_1, am_2, pm_1, pm_2, pm_3, pm_4 }

extension ScheduleExtension on ClassTime {
  int get id => [1, 2, 3, 4, 5, 6][index];

  String get timeRange => [
        "8:30--10:05",
        "10:25--12:00",
        "13:30--15:05",
        "15:25--17:00",
        "18:30--20:05",
        "20:25--22:00"
      ][index];
}

class PlanDate {
  final int day;
  final int week;

  PlanDate(this.week, this.day);

  @override
  String toString() => '($week : $day)';
}

extension DateTimeExtension on DateTime {
  List<PlanDate> get convertedWeekAndDay {
    var start = Time.semesterStart();
    return thisWeek
        .map((e) =>
            PlanDate(e._weekConversion(start), e._weekdayConversion(start)))
        .toList();
  }

  int get convertedWeek => convertedWeekAndDay.first.week;

  DateTime get weekStart {
    var days = -weekday + 1;
    return add(Duration(days: days))._dayStart;
  }

  // error:   DateTime(2021,2,17,25,0).isToday => true  today: 17
  bool get isToday {
    var now = Time.checkDateTimeAvailable(DateTime.now());
    if (!now.isBefore22) {
      now = now.next;
    }
    return _dayStart.difference(now._dayStart).inDays == 0;
  }

  bool get isBefore22 => difference(DateTime(year, month, day, 22)).isNegative;

  DateTime get _dayStart => DateTime(year, month, day);

  int _weekConversion(DateTime start) => difference(start).inDays ~/ 7 + 1;

  int _weekdayConversion(DateTime start) => difference(start).inDays % 7 + 1;

  bool get isThisWeek {
    var begin = DateTime(year).weekStart;
    return _weekConversion(begin) ==
        Time.checkDateTimeAvailable(DateTime.now())._weekConversion(begin);
  }

  List<DateTime> get thisWeek => Time.week
      .asMap()
      .keys
      .map((i) => weekStart.add(Duration(days: i)))
      .toList();

  bool isTheSameWeek(DateTime dateTime) =>
      weekStart.difference(dateTime.weekStart).inDays == 0;

  bool isTheSameDay(DateTime dateTime) =>
      _dayStart.difference(dateTime._dayStart).inDays == 0;

  DateTime get next => _dayStart.add(const Duration(days: 1));
}
