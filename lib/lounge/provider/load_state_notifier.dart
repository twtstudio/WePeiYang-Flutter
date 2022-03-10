// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/widgets/loading.dart';
import 'package:we_pei_yang_flutter/lounge/provider/building_data_provider.dart';
import 'package:we_pei_yang_flutter/lounge/provider/config_provider.dart';

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
  var _state = LoadState.init;

  LoadState get state => _state;

  void stateInit() {
    _state = LoadState.init;
    notifyListeners();
  }

  void stateRefreshing() {
    _state = LoadState.refresh;
    debugPrint('stateRefreshing');
    notifyListeners();
  }

  void stateSuccess() {
    _state = LoadState.success;
    debugPrint('stateSuccess');
    notifyListeners();
  }

  void stateError() {
    _state = LoadState.error;
    notifyListeners();
  }
}

/// 每个页面具体控制数据的ChangeNotifier的父类，方便刷新数据
abstract class LoungeConfigChangeNotifier extends LoadStateChangeNotifier {
  @protected
  void getNewData(BuildingData data);

  @protected
  void getDataError();

  void update(
    LoungeConfig config,
    BuildingData data,
  ) {
    if (data.state.isInit) {
      stateInit();
    } else if (data.state.isRefresh) {
      stateRefreshing();
    } else if (data.state.isSuccess) {
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

  Widget init(BuildContext context) {
    return const Center(child: Loading());
  }

  Widget refresh(BuildContext context) {
    return const Center(child: Loading());
  }

  Widget success(BuildContext context) {
    return const Center(child: Text('success'));
  }

  Widget error(BuildContext context) {
    return const Center(child: Text('error'));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.select((T data) => data.state);

    switch (state) {
      case LoadState.init:
        return init(context);
      case LoadState.refresh:
        return refresh(context);
      case LoadState.success:
        return success(context);
      case LoadState.error:
        return error(context);
    }
  }
}
