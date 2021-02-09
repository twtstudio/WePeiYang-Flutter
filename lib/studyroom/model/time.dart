class Time {

  static const monday = 'Monday';
  static const tuesday = 'Tuesday';
  static const wednesday = 'Wednesday';
  static const thursday = 'Thursday';
  static const friday = 'Friday';
  static const saturday = 'Saturday';
  static const sunday = 'Sunday';

  static List<String> week = [
    monday,
    tuesday,
    wednesday,
    thursday,
    friday,
    saturday,
    saturday
  ];


  static int _daysBetween(DateTime a, DateTime b, [bool ignoreTime = false]) {
    if (ignoreTime) {
      int v = a.millisecondsSinceEpoch ~/ 86400000 -
          b.millisecondsSinceEpoch ~/ 86400000;
      if (v < 0) return -v;
      return v;
    } else {
      int v = a.millisecondsSinceEpoch - b.millisecondsSinceEpoch;
      if (v < 0) v = -v;
      return v ~/ 86400000;
    }
  }

  static int weekOfYear(DateTime date) {
    var start = DateTime(date.year);
    var betweenDays = _daysBetween(start, date) + 1;
    return betweenDays ~/ 7 + 1;
  }

  static bool availableNow(String state, Schedule time) {
    if (state == null) {
      return null;
    } else {
      var list = state.split('');
      if (list[time.id * 2 - 1] == '0' && list[time.id * 2 - 2] == '0') {
        return true;
      } else {
        return false;
      }
    }
  }

  static Schedule classOfDay(DateTime date) {
    var h = date.hour;
    print(date);
    if (h < 10) {
      return Schedule.am_1;
    } else if (h < 12) {
      return Schedule.am_2;
    } else if (h < 15) {
      return Schedule.pm_1;
    } else if (h < 17) {
      return Schedule.am_2;
    } else if (h < 20) {
      return Schedule.pm_3;
    } else if (h < 22) {
      return Schedule.pm_4;
    } else {
      // 晚上十点以后显示第二天早上第一节课
      return Schedule.am_1;
    }
  }

  static List<Schedule> get rangeList => [
        Schedule.am_1,
        Schedule.am_2,
        Schedule.pm_1,
        Schedule.pm_2,
        Schedule.pm_3,
        Schedule.pm_4
      ];
}

enum Schedule { am_1, am_2, pm_1, pm_2, pm_3, pm_4 }

extension ScheduleExtension on Schedule {
  int get id => [1, 2, 3, 4, 5, 6][this.index];

  String get timeRange => [
        "8:30--10:05",
        "10:25--12:00",
        "13:30--15:05",
        "15:25--17:00",
        "18:30--20:05",
        "20:25--22:00"
      ][this.index];
}
