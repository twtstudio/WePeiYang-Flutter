// @dart = 2.12

part of 'update_manager.dart';

abstract class UpdateStatusListener extends ChangeNotifier {
  double _progress = 0;

  double get progress => _progress;

  set progress(double value) {
    if (_progress == value) return;
    _progress = value;
    notifyListeners();
  }

  UpdateStatus _status = UpdateStatus.idle;

  UpdateStatus get status => _status;

  setIdle() {
    _status = UpdateStatus.idle;
  }

  setGetVersion() {
    _status = UpdateStatus.getVersion;
  }

  setDownload() {
    _status = UpdateStatus.download;
  }

  setLoad() {
    _status = UpdateStatus.load;
  }

  setError() {
    _status = UpdateStatus.error;
  }
}

/// 检查更新状态
enum UpdateStatus {
  /// 没有事情正在发生
  idle,

  /// 正在获取最新版本
  getVersion,

  /// 正在下载
  download,

  /// 加载最新版
  load,

  /// 下载失败
  error,
}

extension UpdateStatusExt on UpdateStatus {
  bool get isIdle => this == UpdateStatus.idle;

  bool get isGetVersion => this == UpdateStatus.getVersion;

  bool get isDownload => this == UpdateStatus.download;

  bool get isLoad => this == UpdateStatus.load;

  bool get isError => this == UpdateStatus.error;
}
