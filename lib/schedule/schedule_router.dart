import 'package:flutter/material.dart' show Widget;
import 'package:we_pei_yang_flutter/schedule/view/exam_page.dart';
import 'package:we_pei_yang_flutter/schedule/view/schedule_page.dart';

class ScheduleRouter {
  static String schedule = 'schedule/home';
  static String exam = 'schedule/exam';

  static final Map<String, Widget Function(Object arguments)> routers = {
    schedule: (_) => SchedulePage(),
    exam: (_) => ExamPage(),
  };
}