import 'package:flutter/material.dart';

import '../home/view/home_page.dart';

class FeedbackRouter {
  static String home = 'feedback/home';

  static final Map<String, Widget Function(Object arguments)> routers = {
    home: (_) => HomePage(),
  };
}
