// @dart = 2.12
import 'package:flutter/foundation.dart';
import 'package:we_pei_yang_flutter/commons/channel/download/download_manager.dart';
import 'package:we_pei_yang_flutter/commons/channel/install/hotfix.dart';
import 'package:we_pei_yang_flutter/commons/update/version_data.dart';
import 'package:we_pei_yang_flutter/commons/util/logger.dart';

void hotFix(
  Version version, {
  required Function fixError,
  required Function fixLoadSoFileSuccess,
  StartErrorCallback? startError,
  PendingCallback? download_pending,
  RunningCallback? download_running,
  PausedCallback? download_paused,
  required FailedCallback download_failed,
  SuccessCallback? download_success,
}) {
  // if (kDebugMode) {
  //   fixError.call(Exception('debug版本不能热更新'));
  //   ToastProvider.error('debug版本不能热更新');
  //   return;
  // }
  final fileName =
      "${version.versionCode}-${version.flutterFixCode}-libapp.zip";
  DownloadManager.getInstance().download(
      DownloadTask(
        url: version.flutterFixSo,
        fileName: fileName,
        showNotification: false,
        type: DownloadType.hotfix,
      ),
      startError: startError,
      download_pending: download_pending,
      download_running: download_running,
      download_paused: download_paused, download_failed: (task, _, __) {
    if (task.type == DownloadType.hotfix) {
      // 下载热修复文件失败，那么就弹出下载APK的对话框
      fixError();
    } else {
      download_failed(task, _, __);
    }
  }, download_success: (task) async {
    download_success?.call(task);
    try {
      await HotFixManager.hotFix(task.path);
      debugPrint("fixLoadSoFileSuccess");
      fixLoadSoFileSuccess.call();
    } catch (e, s) {
      Logger.reportError(e, s);
      fixError();
    }
  });
}
