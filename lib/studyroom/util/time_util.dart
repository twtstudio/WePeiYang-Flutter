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
    var firstDay = DateTime.tryParse(CommonPreferences.termStartDate.value);
    if (firstDay != null) {
      // 防止错误
      return firstDay.next.weekStart;
    } else {
      // 想想办法
      if (EnvConfig.isTest) {
        throw Exception('can not get semester start time');
      }
      return DateTime(2021, 8, 16);
    }
  }

  static bool availableNow(String state, ClassTimerange time) {
    var timeJudge = (ClassTimerange time) {
      var list = state.split('');
      if (list[time.id * 2 - 1] == '0' && list[time.id * 2 - 2] == '0') {
        return true;
      } else {
        return false;
      }
    };

    return state.isNotEmpty && timeJudge(time);
  }

  static ClassDateTimerange getDateTimeRange(DateTime date) {
    var h = date.hour;
    final timeSeps = [10, 12, 15, 17, 20, 22];
    ClassTimerange ct = ClassTimerange.am_1;
    if (h > timeSeps.last) {
      return ClassDateTimerange(date.next, ClassTimerange.am_1);
    }
    for (int i = 0; i < timeSeps.length; i++) {
      if (h < timeSeps[i]) {
        ct = ClassTimerange.values[i];
        break;
      }
    }
    return ClassDateTimerange(date, ct);
  }

  static DateTime checkDateTimeAvailable(DateTime dateTime) {
    if (dateTime.isBefore(Time.semesterStart())) {
      return Time.semesterStart();
    }
    return dateTime;
  }

  static List<ClassTimerange> get rangeList => [
        ClassTimerange.am_1,
        ClassTimerange.am_2,
        ClassTimerange.pm_1,
        ClassTimerange.pm_2,
        ClassTimerange.pm_3,
        ClassTimerange.pm_4
      ];
}

/// 日期和时间段
class ClassDateTimerange {
  final DateTime date;
  final ClassTimerange classTime;

  ClassDateTimerange(this.date, this.classTime);
}

enum ClassTimerange { am_1, am_2, pm_1, pm_2, pm_3, pm_4 }

extension ClassTimerangeExtension on ClassTimerange {
  int get id => [1, 2, 3, 4, 5, 6][index];

  String get timeRange => [
        "8:30--10:05",
        "10:25--12:00",
        "13:30--15:05",
        "15:25--17:00",
        "18:30--20:05",
        "20:25--22:00"
      ][index];

  static ClassTimerange current() {
    return Time.getDateTimeRange(DateTime.now()).classTime;
  }
}

class StudyRoomDate {
  late int day;
  late int week;

  StudyRoomDate(this.week, this.day);

  StudyRoomDate.fromDate(DateTime date) {
    this.week = date.convertedWeek;
    this.day = date.weekday;
  }

  StudyRoomDate.current() {
    final t = DateTime.now();
    this.week = t.convertedWeek;
    this.day = t.weekday;
  }

  @override
  String toString() => '($week : $day)';
}

extension DateTimeExtension on DateTime {
  List<StudyRoomDate> get convertedWeekAndDay {
    var start = Time.semesterStart();
    return thisWeek
        .map((e) => StudyRoomDate(
            e._weekConversion(start), e._weekdayConversion(start)))
        .toList();
  }

  int get convertedWeek => convertedWeekAndDay.first.week;

  DateTime get weekStart {
    var days = -weekday + 1;
    return add(Duration(days: days)).dayStart;
  }

  // error:   DateTime(2021,2,17,25,0).isToday => true  today: 17
  bool get isToday {
    var now = Time.checkDateTimeAvailable(DateTime.now());
    if (!now.isBefore22) {
      now = now.next;
    }
    return dayStart.difference(now.dayStart).inDays == 0;
  }

  bool get isBefore22 => difference(DateTime(year, month, day, 22)).isNegative;

  DateTime get dayStart => DateTime(year, month, day);

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

  DateTime get next => dayStart.add(const Duration(days: 1));
}
