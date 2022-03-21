// @dart = 2.12

import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

class HotFixManager {
  static const _hotfixChannel = MethodChannel("com.twt.service/hot_fix");

  static Future<void> hotFix(String path) async {
    await _hotfixChannel.invokeMethod("hotFix", {"path": path});;
  }

  static Future<void> restartApp() async {
    try {
      await _hotfixChannel.invokeMethod("restartApp");
    } catch (e) {
      ToastProvider.error("请手动重启应用");
    }
  }
}