// @dart=2.12

import 'package:we_pei_yang_flutter/studyroom/util/time_util.dart';

extension WPYDateTimeExtension on DateTime {
  bool isSameWeek(DateTime dateTime) =>
      this.weekStart.difference(dateTime.weekStart).inDays == 0;

  bool isSameDay(DateTime dateTime) =>
      this.dayStart.difference(dateTime.dayStart).inDays == 0;
}
