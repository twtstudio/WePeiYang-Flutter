// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/urgent_report/building_card_page.dart';
import 'package:we_pei_yang_flutter/urgent_report/main_page.dart';

class ReportRouter {
  static const String main = 'report/main';
  static const String pass = 'report/domain';

  static final Map<String, Widget Function(dynamic arguments)> routers = {
    main: (arguments) => ReportMainPage(),
    pass: (arguments) => NucPassportPage(),
  };
}
