import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/util/logger.dart';
import 'package:we_pei_yang_flutter/commons/util/storage_util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';

import 'download_item.dart';
import 'download_listener.dart';

export 'download_item.dart';
export 'download_listener.dart';

const _downloadChannel = MethodChannel('com.twt.service/download');

typedef StartErrorCallback = void Function();

StartErrorCallback defaultStartErrorCallback = () {
  ToastProvider.error("创建下载任务失败");
};

class DownloadManager {
  DownloadManager._() {
    _clearTemporaryFiles();
    _downloadChannel.setMethodCallHandler((call) {
      switch (call.method) {
        case 'updateProgress':
          _updateProgress(call);
          break;
        default:
          break;
      }
      return Future.value(0);
    });
  }

  void _clearTemporaryFiles() {
    for (final file in StorageUtil.downloadDir.listSync(recursive: true)) {
      if (file.path.endsWith(".temporary")) {
        try {
          file.deleteSync();
          debugPrint("delete file: ${file.path}");
        } catch (e, s) {
          Logger.reportError(e, s);
        }
      }
    }
  }

  void _updateProgress(MethodCall call) {
    final list = (call.arguments as List).cast<Map>();
    for (var item in list) {
      try {
        final listenerId = item['listenerId'];
        final taskId = item['id'];
        final listener = listeners[listenerId]!;
        final task = listener.tasks[taskId]!;
        final status = item['status'];
        final progress = item['progress'];
        final reason = item['reason'];
        switch (status) {
          case const (1 << 0): // DownloadManager.STATUS_PENDING
            listener.pending?.call(task);
            break;
          case const (1 << 1): // DownloadManager.STATUS_RUNNING
            listener.running?.call(task, progress);
            break;
          case const (1 << 2): // DownloadManager.STATUS_PAUSED
            listener.paused?.call(task, progress);
            break;
          case const (1 << 3): // DownloadManager.STATUS_SUCCESSFUL
            listener.success.call(task);
            listener.downloadList.add(taskId);

            var successNum = listener.downloadList.length;
            var failedNum = listener.failedList.length;
            var tasksNum = listener.tasks.length;
            // 判断是否全部成功
            if (successNum == tasksNum) {
              final paths = List.generate(tasksNum,
                  (index) => listener.tasks.values.toList()[index].path);
              listener.allSuccess?.call(paths);
            }
            // 判断是否全部结束
            if (successNum + failedNum == tasksNum) {
              listener.allComplete?.call(successNum, failedNum);
            }
            break;
          case const (1 << 4): // DownloadManager.STATUS_FAILED
            listener.failed(task, progress, reason);
            listener.failedList.add(taskId);
            break;
        }
      } catch (e, s) {
        Logger.reportError(e, s);
      }
    }
  }

  static DownloadManager? _instance;

  factory DownloadManager.getInstance() {
    _instance ??= DownloadManager._();
    return _instance!;
  }

  final listeners = <String, DownloadListener>{};

  void downloads(
    List<DownloadTask> tasks, {
    StartErrorCallback? startError,
    PendingCallback? download_pending,
    RunningCallback? download_running,
    PausedCallback? download_paused,
    required FailedCallback download_failed,
    required SuccessCallback download_success,
    AllSuccessCallback? all_success,
    AllCompleteCallback? all_complete,
  }) async {
    try {
      // filter tasks
      final downloadedList = <DownloadTask>[];
      tasks.removeWhere((task) {
        if (task.exist) {
          downloadedList.add(task);
          return true;
        }
        return false;
      });
      downloadedList.forEach(download_success);
      if (tasks.isEmpty) {
        all_success?.call(downloadedList.map((e) => e.path).toList());
        return;
      }

      final listener = DownloadListener(
        list: tasks,
        pending: download_pending,
        running: download_running,
        paused: download_paused,
        failed: download_failed,
        success: download_success,
        allSuccess: all_success,
        allComplete: all_complete,
      );
      listeners[listener.listenerId] = listener;

      await _downloadChannel.invokeMethod(
        "addDownloadTask",
        {"downloadList": DownloadList(tasks).toJson()},
      );
    } catch (e, s) {
      Logger.reportError(e, s);
      (startError ?? defaultStartErrorCallback).call();
    }
  }

  void download(
    DownloadTask task, {
    StartErrorCallback? startError,
    PendingCallback? download_pending,
    RunningCallback? download_running,
    PausedCallback? download_paused,
    required FailedCallback download_failed,
    required SuccessCallback download_success,
    AllSuccessCallback? all_success,
    AllCompleteCallback? all_complete,
  }) {
    downloads(
      [task],
      startError: startError,
      download_pending: download_pending,
      download_running: download_running,
      download_paused: download_paused,
      download_failed: download_failed,
      download_success: download_success,
      all_success: all_success,
      all_complete: all_complete,
    );
  }
}
