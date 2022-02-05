// @dart = 2.12
import 'package:flutter/services.dart';

const _installChannel = MethodChannel('com.twt.service/install');

void install(String apkName) {
  var argument = {'apkName': apkName};
  _installChannel.invokeMethod('install', argument);
}
