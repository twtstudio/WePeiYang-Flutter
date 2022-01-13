// @dart = 2.12
import 'download_item.dart';

class DownloadListener {
  final String listenerId;
  final Map<String, DownloadItem> tasks;
  final void Function(String message) error;
  final void Function(DownloadItem task) success;
  final void Function()? begin;
  final void Function(DownloadItem task, double progress)? running;
  final void Function(List<String> paths)? allSuccess;
  final AddTaskCallback addTaskCallback;
  final DownloadingCallback downloadingCallBack;

  DownloadListener._(
    this.listenerId,
    this.tasks,
    this.error,
    this.success,
    this.begin,
    this.running,
    this.allSuccess,
    this.addTaskCallback,
    this.downloadingCallBack,
  );

  factory DownloadListener(
    List<DownloadItem> list,
    void Function(String message) error,
    void Function(DownloadItem task) success,
    void Function()? begin,
    void Function(DownloadItem task, double progress)? running,
    void Function(List<String> paths)? allSuccess,
    void Function(String message)? argumentError,
    void Function(String message)? configError,
    void Function(String message)? registerError,
    void Function(String message)? addTasksError,
    void Function(String message)? downloadError,
    void Function(String message)? removeRegisterError,
  ) {
    final addTaskCallback = AddTaskCallback(
      error,
      argumentError,
      configError,
      registerError,
      addTasksError,
    );

    final downloadingCallback = DownloadingCallback(
      error,
      downloadError,
      removeRegisterError,
    );

    final id = "${DateTime.now().millisecondsSinceEpoch}+${list.length}";

    final tasks = Map.fromIterables(
      list.map((e) {
        e.listenerId = id;
        return e.id;
      }).toList(),
      list,
    );

    return DownloadListener._(
      id,
      tasks,
      error,
      success,
      begin,
      running,
      allSuccess,
      addTaskCallback,
      downloadingCallback,
    );
  }
}

class AddTaskCallback {
  final void Function(String message) defaultError;
  final void Function(String message)? argumentError;
  final void Function(String message)? configError;
  final void Function(String message)? registerError;
  final void Function(String message)? addTasksError;

  AddTaskCallback(
    this.defaultError,
    this.argumentError,
    this.configError,
    this.registerError,
    this.addTasksError,
  );
}

class DownloadingCallback {
  final void Function(String message) defaultError;
  final void Function(String message)? downloadError;
  final void Function(String message)? removeRegisterError;

  DownloadingCallback(
    this.defaultError,
    this.downloadError,
    this.removeRegisterError,
  );
}
