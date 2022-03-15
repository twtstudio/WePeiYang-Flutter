// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/lounge/provider/building_data_provider.dart';

// 自习室模块数据控制：
// 第一级：       LoungeConfigProvider： 自习室数据的基本配置（时间，校区）
//              BuildingDataProvider： 自习室的全部数据
// 第二级：       T extends LoungeConfigChangeNotifier
//              _ClassroomsPageData:   教室列表页面数据和ui控制

/// 页面状态
enum LoadState {
  init,
  refresh,
  success,
  error,
}

extension LoadStateExt on LoadState {
  bool get isBusy => this == LoadState.init || this == LoadState.refresh;

  bool get isSuccess => this == LoadState.success;

  bool get isError => this == LoadState.error;

  bool get isInit => this == LoadState.init;

  bool get isRefresh => this == LoadState.refresh;
}

/// 页面状态控制
abstract class LoadStateChangeNotifier with ChangeNotifier {
  var _loadState = LoadState.init;

  LoadState get loadState => _loadState;

  set loadState(LoadState value) {
    _loadState = value;
  }

  // 防止重复刷新
  bool stateInit([String? msg]) {
    if (!_loadState.isInit) {
      _loadState = LoadState.init;
      if (msg != null) {
        debugPrint("================================");
        debugPrint("state to init , msg : " + msg);
        debugPrint("================================");
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  bool stateRefreshing({String? msg, bool notifier = true}) {
    if (!_loadState.isRefresh) {
      _loadState = LoadState.refresh;
      if (msg != null) {
        debugPrint("================================");
        debugPrint("state to refresh , msg : " + msg);
        debugPrint("================================");
      }
      if (notifier) notifyListeners();
      return true;
    }
    return false;
  }

  bool stateSuccess([String? msg]) {
    if (!_loadState.isSuccess) {
      _loadState = LoadState.success;
      if (msg != null) {
        debugPrint("================================");
        debugPrint("state to success , msg : " + msg);
        debugPrint("================================");
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  bool stateError([String? msg]) {
    if (!_loadState.isError) {
      _loadState = LoadState.error;
      if (msg != null) {
        debugPrint("================================");
        debugPrint("state to error , msg : " + msg);
        debugPrint("================================");
      }
      notifyListeners();
      return true;
    }
    return false;
  }
}

/// 每个页面具体控制数据的ChangeNotifier的父类，方便刷新数据
abstract class LoungeDataChangeNotifier extends LoadStateChangeNotifier {
  @protected
  void getNewData(BuildingData data);

  @protected
  void getDataError();

  void update(BuildingData data) {
    if (data.loadState.isInit) {
      stateInit();
    } else if (data.loadState.isRefresh) {
      stateRefreshing();
    } else if (data.loadState.isSuccess) {
      getNewData(data);
    } else {
      getDataError();
    }
  }
}

/// 页面状态监听组件
abstract class LoadStateListener<T extends LoadStateChangeNotifier>
    extends StatelessWidget {
  const LoadStateListener({
    Key? key,
  }) : super(key: key);

  Widget init(BuildContext context, T data) {
    return const Center(child: Loading());
  }

  Widget refresh(BuildContext context, T data) {
    return const Center(child: Loading());
  }

  Widget success(BuildContext context, T data) {
    return const Center(child: Text('success'));
  }

  Widget error(BuildContext context, T data) {
    return const Center(child: Text('error'));
  }

  @override
  Widget build(BuildContext context) {
    final loadState = context.select((T data) => data.loadState);
    final data = context.read<T>();
    switch (loadState) {
      case LoadState.init:
        return init(context, data);
      case LoadState.refresh:
        return refresh(context, data);
      case LoadState.success:
        return success(context, data);
      case LoadState.error:
        return error(context, data);
    }
  }
}
