// @dart = 2.12
import 'package:flutter/material.dart' show Widget;
import 'package:we_pei_yang_flutter/auth/view/info/tju_bind_page.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/gpa/view/gpa_page.dart';

class GPARouter {
  static String gpa = 'gpa/home';

  static final Map<String, Widget Function(dynamic arguments)> routers = {
    gpa: (_) {
      if (!CommonPreferences.isBindTju.value) return TjuBindPage(gpa);
      return GPAPage();
    },
  };
}
