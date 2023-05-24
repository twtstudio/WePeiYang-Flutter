import 'package:flutter/material.dart' show Widget;
import 'font_test_page.dart';
import 'push_test_page.dart';
import 'qnhd_test_page.dart';
import 'test_main_page.dart';
import 'update_test_page.dart';

class TestRouter {
  static final String pushTest = 'test/push';
  static final String updateTest = 'test/update';
  static final String qsltTest = 'test/qslt';
  static final String fontTest = 'test/font';
  static final String mainPage = 'test/main';

  static final Map<String, Widget Function(dynamic arguments)> routers = {
    pushTest: (_) => const PushTestPage(),
    updateTest: (_) => const UpdateTestPage(),
    qsltTest: (_) => const QsltTestPage(),
    fontTest: (_) => const FontTestPage(),
    mainPage: (_) => const TestMainPage(),
  };
}
