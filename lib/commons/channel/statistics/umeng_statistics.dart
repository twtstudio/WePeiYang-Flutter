// @dart = 2.12
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/util/logger.dart';

class UmengCommonSdk {
  static const MethodChannel _channel =
      const MethodChannel('com.twt.service/umeng_statistics');

  static Future<void> initCommon() async {
    await _channel.invokeMethod('initCommon').catchError(printError);
  }

  static void onEvent(String event, Map<String, dynamic> properties) {
    List<dynamic> args = [event, properties];
    _channel.invokeMethod('onEvent', args).catchError(printError);
  }

  static void onPageStart(String viewName) {
    _channel.invokeMethod('onPageStart', {"page": viewName}).catchError(printError);
  }

  static void onPageEnd(String viewName) {
    _channel.invokeMethod('onPageEnd', {"page": viewName}).catchError(printError);
  }

  static void reportError(String error) {
    _channel.invokeMethod('reportError', {"error": error}).catchError(printError);
  }

  static void onProfileSignIn(String userID) {
    _channel.invokeMethod('onProfileSignIn', {"userID": userID}).catchError(printError);
  }

  static void onProfileSignOff() {
    _channel.invokeMethod('onProfileSignOff').catchError(printError);
  }

  static void printError(e, s)=> Logger.reportError(e, s);
}
