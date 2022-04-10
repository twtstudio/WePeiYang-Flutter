// @dart = 2.12
import 'package:flutter/material.dart' show Widget;
import 'package:we_pei_yang_flutter/schedule/page/course_page.dart';
import 'package:we_pei_yang_flutter/schedule/page/custom_courses_page.dart';
import 'package:we_pei_yang_flutter/schedule/page/exam_page.dart';

class ScheduleRouter {
  static String course = 'schedule/course';
  static String exam = 'schedule/exam';
  static String customCourse = 'schedule/customCourse';

  static final Map<String, Widget Function(Object arguments)> routers = {
    course: (_) => CoursePage(),
    exam: (_) => ExamPage(),
    customCourse: (_) => CustomCoursesPage(),
  };
}