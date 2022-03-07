// @dart = 2.12
import 'dart:async';

import 'package:flutter/services.dart';

class UmengCommonSdk {
  static const MethodChannel _channel =
      const MethodChannel('com.twt.service/umeng_statistics');

  static Future<void> initCommon() async {
    await _channel.invokeMethod('initCommon');
  }

  static void onEvent(String event, Map<String, dynamic> properties) {
    List<dynamic> args = [event, properties];
    _channel.invokeMethod('onEvent', args);
  }

  static void onPageStart(String viewName) {
    _channel.invokeMethod('onPageStart', {"page": viewName});
  }

  static void onPageEnd(String viewName) {
    _channel.invokeMethod('onPageEnd', {"page": viewName});
  }

  static void reportError(String error) {
    _channel.invokeMethod('reportError', {"error": error});
  }
}
