// @dart = 2.12

import 'package:flutter/material.dart' show Widget;
import 'package:we_pei_yang_flutter/commons/test/push_test_page.dart';
import 'package:we_pei_yang_flutter/commons/test/update_test_page.dart';

class TestRouter {
  static String pushTest = 'common/pushTest';
  static String updateTest = 'common/updateTest';

  static final Map<String, Widget Function(Object arguments)> routers = {
    pushTest: (_) => const PushTestPage(),
    updateTest:(_) => const UpdateTestPage(),
  };
}