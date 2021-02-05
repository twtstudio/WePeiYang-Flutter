import 'package:flutter/material.dart' show Widget;
import 'package:wei_pei_yang_demo/gpa/view/gpa_page.dart';

class GPARouter {
  static String gpa = '/gpa';

  static final Map<String, Widget Function(Object arguments)> routers = {
    gpa:(_) => GPAPage(),
  };
}
