// @dart = 2.12
import 'package:flutter/services.dart';

class InstallUtil {
  static const _installChannel = MethodChannel('com.twt.service/install');

  static void install(String path) {
    var argument = {'path': path};
    _installChannel.invokeMethod('install', argument);
  }
}
