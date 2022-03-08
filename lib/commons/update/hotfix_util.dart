// @dart = 2.12

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/download/download_manager.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

const _hotfixChannel = MethodChannel("com.twt.service/hot_fix");

void hotFix(
  String url,
  int versionCode,
  int fixCode, {
  required void Function(dynamic) fixError,
  required Function fixLoadSoFileSuccess,
  required void Function(dynamic) downloadError,
  void Function()? downloadBegin,
  void Function(DownloadItem task, double progress)? downloadRunning,
  void Function(String soPath)? fixDownloadSuccess,
}) {
  if (kDebugMode) {
    fixError.call(Exception('debug版本不能热更新'));
    ToastProvider.error('debug版本不能热更新');
    return;
  }
  final fileName = "$versionCode-$fixCode-libapp.so";
  DownloadManager.getInstance().download(
    DownloadItem(
      url: url,
      fileName: fileName,
      showNotification: false,
      type: DownloadType.hotfix,
    ),
    error: downloadError,
    success: (item) {},
    begin: downloadBegin,
    running: downloadRunning,
    allSuccess: (list) async {
      final path = list.first;
      fixDownloadSuccess?.call(path);
      try {
        await _hotfixChannel.invokeMethod("hotFix", {"path": path});;
        fixLoadSoFileSuccess.call();
      } catch (e) {
        fixError.call(e);
      }
    },
  );
}

Future<void> restartApp() async {
  try {
    await _hotfixChannel.invokeMethod("restartApp");
  } catch (e) {
    ToastProvider.error("请手动重启应用");
  }
}
