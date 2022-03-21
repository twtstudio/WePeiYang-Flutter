// @dart = 2.12

part of 'update_manager.dart';

abstract class UpdateListener extends ChangeNotifier {
  double _progress = 0;

  double get progress => _progress;

  set progress(double value) {
    _progress = value;
    notifyListeners();
  }

  UpdateState _state = UpdateState.idle;

  UpdateState get state => _state;

  set state(UpdateState value) {
    _state = value;
    notifyListeners();
  }

  setIdle() {
    _state = UpdateState.idle;
    notifyListeners();
  }

  setGetVersion() {
    _state = UpdateState.getVersion;
    notifyListeners();
  }

  setDownload() {
    _state = UpdateState.download;
    notifyListeners();
  }

  setLoad() {
    _state = UpdateState.load;
    notifyListeners();
  }
}

enum UpdateState {
  idle,
  getVersion,
  download,
  load,
}

extension UpdateStateExt on UpdateState {

  bool get isIdle => this == UpdateState.idle;

  bool get isGetVersion => this == UpdateState.getVersion;

  bool get isDownload => this == UpdateState.download;

  bool get isLoad => this == UpdateState.load;
}