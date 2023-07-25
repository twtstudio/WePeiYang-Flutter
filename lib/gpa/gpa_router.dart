import 'package:flutter/material.dart' show Widget;
import 'package:we_pei_yang_flutter/gpa/view/gpa_page.dart';

class GPARouter {
  static String gpa = 'gpa/home';

  static final Map<String, Widget Function(dynamic arguments)> routers = {
    gpa: (_) => GPAPage(),
  };
}
