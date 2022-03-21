// @dart = 2.12
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'download_item.dart';
import 'download_listener.dart';

export 'download_item.dart';

const _downloadChannel = MethodChannel('com.twt.service/download');

// TODO: 选择下载失败时是终止还是忽略
// TODO: 改成单例模式，实现可以在两个不同地方下载任务，并且回调 (实现了一半)
// TODO: 可以对一个观察者添加或修改回调
class DownloadManager {
  DownloadManager._() {
    _downloadChannel.setMethodCallHandler((call) {
      switch (call.method) {
        case 'updateProgress':
          final id = call.arguments['listenerId'].toString();
          debugPrint('listeners : ${listeners.keys}');
          debugPrint('${call.arguments}');
          if (listeners.containsKey(id)) {
            _updateProgress(listeners[id]!, call);
          } else if (id == "all") {
            for (var listener in listeners.values) {
              _updateProgress(listener, call);
            }
          } else if (id == "unknown") {
            // TODO
          } else {
            // TODO
          }
          break;
        default:
          break;
      }
      // ??
      return Future.value(0);
    });
  }

  void _updateProgress(DownloadListener listener, MethodCall call) {
    switch (call.arguments['state']) {
      case 'SUCCESS':
        final taskId = call.arguments['taskId'];
        final path = call.arguments['path'];
        if (listener.tasks.containsKey(taskId)) {
          final task = listener.tasks[taskId]!;
          task.resultPath = path;
          listener.success.call(task);
        } else {
          // TODO
        }
        break;
      case 'RUNNING':
        final taskId = call.arguments['taskId'];
        final progress = call.arguments['progress'] as double;
        if (listener.tasks.containsKey(taskId)) {
          final task = listener.tasks[taskId]!;
          listener.running?.call(task, progress);
        } else {
          // TODO
        }
        break;
      case 'ALL_SUCCESS':
        debugPrint('all success');
        final resultPaths =
            listener.tasks.values.map((e) => e.resultPath).toList();
        listener.allSuccess?.call(resultPaths);
        break;
      case 'ERROR':
        listener.error(call.arguments.toString());
        break;
      case 'BEGIN':
        listener.begin?.call();
        break;
      default:
        break;
    }
  }

  static DownloadManager? _instance;

  factory DownloadManager.getInstance() {
    _instance ??= DownloadManager._();
    return _instance!;
  }

  final listeners = <String, DownloadListener>{};

  void downloads(
    List<DownloadItem> tasks, {
    required void Function(dynamic) error,
    required void Function(DownloadItem task) success,
    void Function()? begin,
    void Function(DownloadItem task, double progress)? running,
    void Function(List<String> paths)? allSuccess,
  }) async {
    final listener = DownloadListener(
      tasks,
      error,
      success,
      begin,
      running,
      allSuccess,
    );
    listeners[listener.listenerId] = listener;

    try {
      await _downloadChannel.invokeMethod(
        "addDownloadTask",
        {
          "downloadList": DownloadList(tasks).toJson(),
        },
      );
      ;
    } catch (e) {
      error.call(e);
    }
  }

  void download(
    DownloadItem task, {
    required void Function(dynamic) error,
    required void Function(DownloadItem task) success,
    void Function()? begin,
    void Function(DownloadItem task, double progress)? running,
    void Function(List<String> paths)? allSuccess,
  }) {
    downloads(
      [task],
      error: error,
      success: success,
      begin: begin,
      running: running,
      allSuccess: allSuccess,
    );
  }
}
