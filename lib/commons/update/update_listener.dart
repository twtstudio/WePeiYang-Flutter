// @dart = 2.12

part of 'update_manager.dart';

abstract class UpdateStatusListener extends ChangeNotifier {
  double _progress = 0;

  double get progress => _progress;

  set progress(double value) {
    _progress = value;
    notifyListeners();
  }

  UpdateStatus _status = UpdateStatus.idle;

  UpdateStatus get status => _status;

  setIdle() {
    _status = UpdateStatus.idle;
    notifyListeners();
  }

  setGetVersion() {
    _status = UpdateStatus.getVersion;
    notifyListeners();
  }

  setDownload() {
    _status = UpdateStatus.download;
    notifyListeners();
  }

  setLoad() {
    _status = UpdateStatus.load;
    notifyListeners();
  }
}

/// 检查更新状态
/*

检查更新流程：
                                                    |- 下载成功 --> [load]
                        |- 需要更新   --> [download] -|
[idle] -> [getVersion] -|                           |- 下载失败 ---
 |                      |- 不需要更新 ---                         |
 |                                    |                         |
 <- --- --- --- --- --- --- --- --- <- --- --- --- --- --- --- --
 */
enum UpdateStatus {
  /// 没有事情正在发生
  idle,

  /// 正在获取最新版本
  getVersion,

  /// 正在下载
  download,

  /// 加载最新版
  load,
}

extension UpdateStatusExt on UpdateStatus {
  bool get isIdle => this == UpdateStatus.idle;

  bool get isGetVersion => this == UpdateStatus.getVersion;

  bool get isDownload => this == UpdateStatus.download;

  bool get isLoad => this == UpdateStatus.load;
}
