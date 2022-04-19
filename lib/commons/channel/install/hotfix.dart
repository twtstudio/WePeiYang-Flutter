// @dart = 2.12

import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/util/logger.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

class HotFixManager {
  static const _hotfixChannel = MethodChannel("com.twt.service/hot_fix");

  static Future<void> hotFix(String path) async {
    await _hotfixChannel.invokeMethod("hotFix", {"path": path});
  }

  static Future<void> restartApp() async {
    try {
      await _hotfixChannel.invokeMethod("restartApp");
    } catch (e) {
      ToastProvider.error("请手动重启应用");
    }
  }

  /// 是否已下载热修复文件及是否可用
  ///
  /// null: 没有这个文件
  ///
  /// true: 有这个文件且能使用
  ///
  /// false: 有这个文件但不能使用
  static Future<bool?> soFileCanUse(String fileName) async {
    try {
      return await _hotfixChannel.invokeMethod(
        "soFileCanUse",
        {"name": fileName},
      );
    } catch (e, s) {
      Logger.reportError(e, s);
      return false;
    }
  }
}
