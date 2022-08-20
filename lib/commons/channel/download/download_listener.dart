// @dart = 2.12
import 'download_item.dart';

typedef PendingCallback = void Function(DownloadTask task);
typedef RunningCallback = void Function(DownloadTask task, double progress);
typedef PausedCallback = void Function(DownloadTask task, double progress);
typedef FailedCallback = void Function(
    DownloadTask task, double progress, String reason);
typedef SuccessCallback = void Function(DownloadTask task);
typedef AllSuccessCallback = void Function(List<String>);
// 参数为任务成功&失败的数量
typedef AllCompleteCallback = void Function(int success, int failed);

class DownloadListener {
  final String listenerId;
  final Map<String, DownloadTask> tasks;
  final PendingCallback? pending;
  final RunningCallback? running;
  final PausedCallback? paused;
  final FailedCallback failed;
  final SuccessCallback success;
  final AllSuccessCallback? allSuccess;
  final AllCompleteCallback? allComplete;
  // 储存下载成功&失败的taskId
  final Set<String> downloadList = Set();
  final Set<String> failedList = Set();

  DownloadListener._(
    this.listenerId,
    this.tasks,
    this.pending,
    this.running,
    this.paused,
    this.failed,
    this.success,
    this.allSuccess,
    this.allComplete,
  );

  factory DownloadListener({
    required List<DownloadTask> list,
    PendingCallback? pending,
    RunningCallback? running,
    PausedCallback? paused,
    required FailedCallback failed,
    required SuccessCallback success,
    AllSuccessCallback? allSuccess,
    AllCompleteCallback? allComplete,
  }) {
    final id = "${DateTime.now().millisecondsSinceEpoch}+${list.length}";

    final tasks = Map.fromIterables(
      list.map((e) {
        e.listenerId = id;
        return e.id;
      }).toList(),
      list,
    );

    return DownloadListener._(id, tasks, pending, running, paused, failed,
        success, allSuccess, allComplete);
  }

  @override
  String toString() {
    return "id: $listenerId ,tasks: $tasks";
  }
}
