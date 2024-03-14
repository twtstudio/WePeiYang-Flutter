import 'package:flutter/material.dart';

class ClassPeriod {
  TimeOfDay startTime;
  TimeOfDay endTime;
  String? displayStart;

  ClassPeriod(this.startTime, this.endTime, {this.displayStart});

  factory ClassPeriod.fromString(String string, {String? displayStart}) {
    var times = string.split('-');

    var startParts = times[0].split(':').map(int.parse).toList();
    var endParts = times[1].split(':').map(int.parse).toList();

    return ClassPeriod(
      TimeOfDay(hour: startParts[0], minute: startParts[1]),
      TimeOfDay(hour: endParts[0], minute: endParts[1]),
      displayStart: displayStart,
    );
  }

  @override
  String toString() {
    var startStr = displayStart ??
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
    ClassPeriod.fromString("7:00-9:15", displayStart: "8:30"),
    ClassPeriod.fromString("9:16-10:05", displayStart: "9:25"),
    ClassPeriod.fromString("10:06-11:10", displayStart: "10:25"),
    ClassPeriod.fromString("11:11-12:00", displayStart: "11:25"),
    //
    ClassPeriod.fromString("12:01-14:15", displayStart: "13:30"),
    ClassPeriod.fromString("14:16-15:05", displayStart: "14:25"),
    ClassPeriod.fromString("15:06-16:10", displayStart: "15:25"),
    ClassPeriod.fromString("16:11-17:00", displayStart: "16:25"),
    //
    ClassPeriod.fromString("17:01-19:15", displayStart: "18:30"),
    ClassPeriod.fromString("19:16-20:05", displayStart: "19:25"),
    ClassPeriod.fromString("20:06-20:55", displayStart: "20:25"),
    ClassPeriod.fromString("20:56-21:45", displayStart: "21:00"),
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
