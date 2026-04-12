import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/streak/view/streak_page.dart';
import 'package:we_pei_yang_flutter/streak/view/day_selection_page.dart';
import 'package:we_pei_yang_flutter/streak/view/task_selection_page.dart';

class StreakRouter {
  static const String streakPage = 'streak/streak_page';
  static const String daySelectionPage = 'streak/day_selection_page';
  static const String taskSelectionPage = 'streak/task_selection_page';

  static final Map<String, Widget Function(dynamic)> routers = {
    streakPage: (context) => const StreakPage(),
    daySelectionPage: (context) => const DaySelectionPage(),
    taskSelectionPage: (args) => TaskSelectionPage(days: args as int),
  };
}