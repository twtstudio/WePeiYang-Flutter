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

  DownloadListener._(
    this.listenerId,
    this.tasks,
    this.error,
    this.success,
    this.begin,
    this.running,
    this.allSuccess,
  );

  factory DownloadListener(
    List<DownloadItem> list,
    void Function(String message) error,
    void Function(DownloadItem task) success,
    void Function()? begin,
    void Function(DownloadItem task, double progress)? running,
    void Function(List<String> paths)? allSuccess,
  ) {

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
    );
  }
}
