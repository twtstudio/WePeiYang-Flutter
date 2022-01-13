// @dart = 2.12
import 'package:flutter/services.dart';
import 'package:we_pei_yang_flutter/commons/download/download_listener.dart';
import 'download_item.dart';

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
          if (listeners.containsKey(id)) {
            _updateProgress(listeners[id]!, call);
          } else if (id == "all") {
            listeners.values.forEach(
              (element) => _updateProgress(element, call),
            );
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
        final resultPaths =
            listener.tasks.values.map((e) => e.resultPath).toList();
        listener.allSuccess?.call(resultPaths);
        break;
      case 'ERROR':
        _catchDownloadError(call, listener.downloadingCallBack);
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
    if (_instance == null) {
      _instance = DownloadManager._();
    }
    return _instance!;
  }

  final listeners = <String, DownloadListener>{};

  void downloads(
    List<DownloadItem> tasks, {
    required void Function(String message) error,
    required void Function(DownloadItem task) success,
    void Function()? begin,
    void Function(DownloadItem task, double progress)? running,
    void Function(List<String> paths)? allSuccess,
    void Function(String message)? argumentError,
    void Function(String message)? configError,
    void Function(String message)? registerError,
    void Function(String message)? addTasksError,
    void Function(String message)? downloadError,
    void Function(String message)? removeRegisterError,
  }) {
    final listener = DownloadListener(
      tasks,
      error,
      success,
      begin,
      running,
      allSuccess,
      argumentError,
      configError,
      registerError,
      addTasksError,
      downloadError,
      removeRegisterError,
    );
    listeners[listener.listenerId] = listener;

    try {
      _downloadChannel.invokeMethod(
        "addDownloadTask",
        {
          "downloadList": DownloadList(tasks).toJson(),
        },
      );
    } on PlatformException catch (e) {
      _catchPlatformError(e.code, e.message ?? "", listener.addTaskCallback);
    } catch (e) {
      error.call(e.toString());
    }
  }

  void download(
    DownloadItem task, {
    required void Function(String message) error,
    required void Function(DownloadItem task) success,
    void Function()? begin,
    void Function(DownloadItem task, double progress)? running,
    void Function(List<String> paths)? allSuccess,
    void Function(String message)? argumentError,
    void Function(String message)? configError,
    void Function(String message)? registerError,
    void Function(String message)? addTasksError,
    void Function(String message)? downloadError,
    void Function(String message)? removeRegisterError,
  }) {
    downloads(
      [task],
      error: error,
      success: success,
      begin: begin,
      running: running,
      allSuccess: allSuccess,
      argumentError: argumentError,
      configError: configError,
      registerError: registerError,
      addTasksError: addTasksError,
      downloadError: downloadError,
      removeRegisterError: removeRegisterError,
    );
  }

  void _catchPlatformError(
    String code,
    String message,
    AddTaskCallback callback,
  ) {
    switch (code) {
      case "PARSE_ARGUMENT_ERROR":
        (callback.argumentError ?? callback.defaultError).call(message);
        break;
      case "CONFIG_DOWNLOAD_ERROR":
        (callback.configError ?? callback.defaultError).call(message);
        break;
      case "REGISTER_OBSERVER_ERROR":
        (callback.registerError ?? callback.defaultError).call(message);
        break;
      case "ADD_TASKS_ERROR":
        (callback.addTasksError ?? callback.defaultError).call(message);
        break;
      default:
        callback.defaultError.call(message);
    }
  }

  void _catchDownloadError(
    MethodCall call,
    DownloadingCallback callback,
  ) {
    final code = call.arguments['code'];
    final message = call.arguments['message'];
    switch (code) {
      case "DOWNLOAD_ERROR":
        (callback.downloadError ?? callback.defaultError).call(message);
        break;
      case "REMOVE_REGISTER_ERROR":
        (callback.removeRegisterError ?? callback.defaultError).call(message);
        break;
      default:
        callback.defaultError.call(message);
    }
  }
}
