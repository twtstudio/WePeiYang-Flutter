// @dart = 2.12
import 'dart:async';

import 'package:flutter/services.dart';

const _hotfixChannel = MethodChannel("com.twt.service/hot_fix");

Future<void> hotFixMoveFile(String path) async {
  return  await _hotfixChannel.invokeMethod("hotFix", {"path": path});
}

Future<void> restart() async => await _hotfixChannel.invokeMethod("restartApp");