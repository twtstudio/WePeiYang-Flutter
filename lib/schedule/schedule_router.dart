// @dart = 2.12
import 'package:flutter/material.dart' show Widget;
import 'package:we_pei_yang_flutter/auth/view/info/tju_bind_page.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/schedule/page/course_page.dart';
import 'package:we_pei_yang_flutter/schedule/page/custom_courses_page.dart';
import 'package:we_pei_yang_flutter/schedule/page/exam_page.dart';
import 'package:we_pei_yang_flutter/schedule/page/edit_detail_page.dart';

import 'model/course.dart';

class ScheduleRouter {
  static String course = 'schedule/course';
  static String exam = 'schedule/exam';
  static String customCourse = 'schedule/customCourse';
  static String editDetail = 'schedule/editDetail';


  static final Map<String, Widget Function(dynamic arguments)> routers = {
    course: (args) {
      if (!CommonPreferences.isBindTju.value) return TjuBindPage(course);
      return CoursePage(args as List<Pair<Course, int>>);
    },
    exam: (_) {
      if (!CommonPreferences.isBindTju.value) return TjuBindPage(exam);
      return ExamPage();
    },
    customCourse: (_) => CustomCoursesPage(),
    editDetail: (args) => EditDetailPage(args as EditDetailPageArgs),
  };
}