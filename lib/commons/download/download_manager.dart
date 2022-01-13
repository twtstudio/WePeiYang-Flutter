import 'package:flutter/services.dart';

import 'download_item.dart';

class DownloadManager {
  static const _downloadChannel = MethodChannel('com.twt.service/download');

  static void download(
    List<Map<String, dynamic>> tasks, {
    void Function(String fileName, double progress) running,
    void Function(String code, String message) error,
    void Function(String fileName, String path) success,
    void Function() allSuccess,
  }) {
    final list = DownloadList.fromList(tasks);
    _downloadChannel.setMethodCallHandler((call) {
      switch (call.method) {
        case 'updateProgress':
          switch (call.arguments['state']) {
            case 'SUCCESS':
              final fileName = call.arguments['fileName'];
              final path = call.arguments['path'];
              success?.call(fileName, path);
              break;
            case 'RUNNING':
              final fileName = call.arguments['fileName'];
              final progress = call.arguments['progress'] as double;
              running?.call(fileName, progress);
              break;
            case 'ALL_SUCCESS':
              allSuccess?.call();
              break;
            case 'ERROR':
              final code = call.arguments['code'];
              final message = call.arguments['message'];
              error?.call(code, message);
              break;
            case 'BEGIN':
              break;
          }
          break;
        default:
      }

      return;
    });

    _downloadChannel.invokeMethod(
      "addDownloadTask",
      {"downloadList": list.toJson()},
    );
  }
}
