// @dart = 2.12

// 自习室数据可能发生的情况
// 1. 有本地数据，成功加载服务器数据： 正常显示
// 2. 有本地数据，加载服务器数据失败： 在页面顶部显示上次刷新时间
// 3. 没有本地数据，成功加载服务器数据： 正常显示
// 4. 没有本地数据，加载服务器数据失败： 显示错误页面
// 所以总共三种情况
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/lounge/server/error.dart';

enum DataState {
  outdated,
  updated,
  empty,
}

class LoungeDataState {
  final DataState state;
  final Object? error;

  LoungeDataState(this.state, this.error);

  factory LoungeDataState.empty(Object? error) {
    return LoungeDataState(DataState.empty, error);
  }

  factory LoungeDataState.updated() {
    return LoungeDataState(DataState.updated, null);
  }

  factory LoungeDataState.outdated(Object? error) {
    return LoungeDataState(DataState.outdated, error);
  }

  bool get isOutdated => this.state == DataState.outdated;

  bool get isUpdated => this.state == DataState.updated;

  bool get isEmpty => this.state == DataState.empty;
}

mixin LoungeDataStateMixin {
  // 数据状态
  LoungeDataState _dataState = LoungeDataState.empty(null);

  LoungeDataState get dataState => _dataState;

  void dataOutdated(Object? error) {
    _dataState = LoungeDataState.outdated(error);
    if (error is LoungeError) {
      error.report();
    }
  }

  void dataUpdated({DateTime? time}) {
    _dataState = LoungeDataState.updated();
    if (time != null){
      CommonPreferences().loungeUpdateTime.value = time.toString();
      _updateTime = time;
    }
  }

  void dataEmpty(Object? error) {
    _dataState = LoungeDataState.empty(error);
    if (error is LoungeError) {
      error.report();
    }
  }

  // 数据刷新时间
  DateTime? _updateTime =
      DateTime.tryParse(CommonPreferences().loungeUpdateTime.value);

  DateTime? get updateTime => _updateTime;
}
