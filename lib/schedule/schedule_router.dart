import 'package:flutter/material.dart' show Widget;
import 'package:wei_pei_yang_demo/schedule/view/schedule_page.dart';

class ScheduleRouter {
  static String schedule = '/schedule';

  static final Map<String, Widget Function(Object arguments)> routers = {
    schedule:(_) => SchedulePage(),
  };
}