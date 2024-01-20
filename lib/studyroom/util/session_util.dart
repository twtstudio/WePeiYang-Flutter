import 'package:flutter/material.dart';

class ClassPeriod {
  TimeOfDay startTime;
  TimeOfDay endTime;

  ClassPeriod(this.startTime, this.endTime);

  factory ClassPeriod.fromString(String string) {
    var times = string.split('-');

    var startParts = times[0].split(':').map(int.parse).toList();
    var endParts = times[1].split(':').map(int.parse).toList();

    return ClassPeriod(
      TimeOfDay(hour: startParts[0], minute: startParts[1]),
      TimeOfDay(hour: endParts[0], minute: endParts[1]),
    );
  }

  @override
  String toString() {
    var startStr =
        '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';
    var endStr = '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}';
    return startStr + '-' + endStr;
  }

  bool isInPeriod(TimeOfDay time) {
    int toMinutes(TimeOfDay tod) => tod.hour * 60 + tod.minute;
    int startMinutes = toMinutes(startTime);
    int endMinutes = toMinutes(endTime);
    int timeMinutes = toMinutes(time);

    return timeMinutes > startMinutes && timeMinutes < endMinutes;
  }
}

class SessionIndexUtil {
  static final List<ClassPeriod> periods = [
    ClassPeriod.fromString("8:00-9:15"),
    ClassPeriod.fromString("9:20-10:05"),
    ClassPeriod.fromString("10:25-11:10"),
    ClassPeriod.fromString("11:15-12:00"),
    ClassPeriod.fromString("13:30-14:15"),
    ClassPeriod.fromString("14:20-15:05"),
    ClassPeriod.fromString("15:25-16:10"),
    ClassPeriod.fromString("16:15-17:00"),
    ClassPeriod.fromString("18:30-19:15"),
    ClassPeriod.fromString("19:20-20:05"),
    ClassPeriod.fromString("20:10-20:55"),
    ClassPeriod.fromString("21:00-21:45"),
  ];

  static int getCurrentSessionIndex() {
    var currentTime = TimeOfDay.now();
    for (int i = 0; i < periods.length; i++) {
      var period = periods[i];
      if (period.isInPeriod(currentTime)) {
        return i + 1;
      }
    }
    return -1;
  }
}
