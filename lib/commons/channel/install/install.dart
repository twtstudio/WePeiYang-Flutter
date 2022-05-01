// @dart = 2.12
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/util/logger.dart';

class InstallManager {
  static const _channel = MethodChannel('com.twt.service/install');
  static bool canGoToMarket = false;

  static void install(String apkName) {
    var argument = {'path': apkName};
    _channel.invokeMethod('install', argument);
  }

  static Future<void> goToMarket() async {
    try {
      await _channel.invokeMethod<bool>("goToMarket");
    } catch (e, s) {
      Logger.reportError(e, s);
    }
  }

  static Future<void> getCanGoToMarket() async {
    try {
      canGoToMarket =
          await _channel.invokeMethod<bool>("canGoToMarket") ?? false;
    } catch (e, s) {
      Logger.reportError(e, s);
    }
  }
}
