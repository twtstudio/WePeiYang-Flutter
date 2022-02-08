// @dart = 2.12

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/download/download_item.dart';
import 'package:we_pei_yang_flutter/commons/download/download_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

const _hotfixChannel = MethodChannel("com.twt.service/hot_fix");

Future<void> hotFixMoveFile(String path) async {
  return  await _hotfixChannel.invokeMethod("hotFix", {"path": path});
}

Future<void> restart() async => await _hotfixChannel.invokeMethod("restartApp");