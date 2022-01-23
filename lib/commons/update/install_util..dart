// @dart = 2.12
import 'package:flutter/services.dart';

class InstallUtil {
  static const _installChannel = MethodChannel('com.twt.service/install');

  static void install(String apkName) {
    var argument = {'apkName': apkName};
    _installChannel.invokeMethod('install', argument);
  }
}
