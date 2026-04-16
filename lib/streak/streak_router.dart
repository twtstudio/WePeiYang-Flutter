import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/streak/view/streak_page.dart';
import 'package:we_pei_yang_flutter/streak/view/day_selection_page.dart';
import 'package:we_pei_yang_flutter/streak/view/task_selection_page.dart';
import 'package:we_pei_yang_flutter/streak/view/daily_progress_page.dart';
import 'package:we_pei_yang_flutter/streak/view/streak_record_page.dart';
import 'package:we_pei_yang_flutter/streak/view/certificate_page.dart';

class StreakRouter {
  static const String streakPage = 'streak/streak_page';
  static const String daySelectionPage = 'streak/day_selection_page';
  static const String taskSelectionPage = 'streak/task_selection_page';
  static const String dailyProgressPage = 'streak/daily_progress_page';
  static const String streakRecordPage = 'streak/streak_record_page';
  static const String certificatePage = 'streak/certificate_page';

  static final Map<String, Widget Function(dynamic)> routers = {
    streakPage: (context) => const StreakPage(),
    daySelectionPage: (context) => const DaySelectionPage(),
    taskSelectionPage: (args) {
      final int days = args as int? ?? 0;
      return TaskSelectionPage(days: days);
    },
    dailyProgressPage: (args) {
      // args may be a Map<String, dynamic> containing days and tasks
      final map = args as Map<String, dynamic>?;
      final int days = map?['days'] as int? ?? 0;
      final List<Map<String, dynamic>> tasks = (map?['tasks'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? const [];
      return DailyProgressPage(days: days, tasks: tasks);
    },
    streakRecordPage: (context) => const StreakRecordPage(),
    certificatePage: (context) => const CertificatePage(),
  };
}