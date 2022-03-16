// @dart = 2.12

import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/lounge/model/building.dart';
import 'package:we_pei_yang_flutter/lounge/model/classroom.dart';
import 'package:we_pei_yang_flutter/lounge/provider/config_provider.dart';
import 'package:we_pei_yang_flutter/lounge/server/error.dart';
import 'package:we_pei_yang_flutter/lounge/server/hive_manager.dart';
import 'package:we_pei_yang_flutter/lounge/server/open_api.dart';
import 'package:we_pei_yang_flutter/lounge/server/search_server.dart';
import 'package:provider/provider.dart';

import 'data_state.dart';
import 'load_state_notifier.dart';

// 1. _allBuildings = database 最新
// 2. _allBuildings 最新  database 非最新
// 3. _allBuildings = database 非最新

class BuildingData extends LoadStateChangeNotifier with LoungeDataStateMixin {
  // 所有教学楼数据
  Map<String, Building> _allBuildings = {};

  Map<String, Building> get buildings => _allBuildings;

  final BuildContext _context;

  BuildingData(this._context);

  /// 卫津路的教学楼
  List<Building> get wjl {
    return buildings.values
        .where(
          (b) => b.campus == Campus.wjl.id,
        )
        .toList()..sort((a,b) => a.name.compareTo(b.name));
  }

  /// 北洋园的教学楼
  List<Building> get byy {
    return buildings.values
        .where(
          (b) => b.campus == Campus.byy.id,
        )
        .toList()..sort((a,b) => a.name.compareTo(b.name));
  }

  Future<void> init() async {
    if(loadState.isInit || loadState.isError){
      await getDataOfWeek();
    }
  }

  /// 刷新指定日期（默认为当前时刻）的那周的数据
  Future<void> getDataOfWeek() async {
    if(loadState.isRefresh) return;
    final time = _context.read<LoungeConfig>().dateTime;
    stateRefreshing();
    // [getBuildingList] 中如果没有成功获取服务器新数据，那么就会加载本地包含时间安排的数据，
    // 所以即使 [getRoomsPlan] 执行失败，_allBuildings 中的数据也是上一次的数据
    // 所以 _allBuildings 中为空或上一次的数据

    final getDataSuccess = (_) {
      dataUpdated(time: time);
      // 只要 _allBuildings 的数据更新了，就会刷新界面
      stateSuccess('update building data success');
      // 只有最新的数据会写入数据库
      LoungeDB().db.writeBuildingData(_allBuildings.values);
    };

    final getDataError = (e) {
      // 如果 _allBuildings 为空，则需要渲染错误页面，否则提示数据未更新
      _allBuildings.isEmpty ? dataEmpty(e) : dataOutdated(e);
      stateError('update building data fail');
    };

    final writeDBError = (e) {
      // 将数据写入数据库失败
      (e as LoungeError).report();
    };

    await getBuildingData(time)
        .then(getDataSuccess, onError: getDataError)
        .catchError(writeDBError, test: (e) => e is LoungeError);
  }

  /// 加载教学楼数据（无教室占用信息）。
  /// 如果成功加载服务器数据，则更新ui，并刷新本地数据库；
  /// 如果没有获得新的数据（网络错误或解析错误），则显示一个提醒（TODO）
  ///
  /// 如果这个方法抛出了错误，则教学楼基本数据没有加载成功，也就没有必要加载
  /// 教室时间占用数据
  Future<void> getBuildingData(DateTime time) async {
    // 1. 加载教学楼数据
    final catchBuildingListNetWork = (error, stack) async {
      LoungeError.network(
        error,
        stackTrace: stack,
        des: 'BuildingData getBuildingList load data error',
      ).report();
      // 如果从网络上加载数据出问题了，那么就加载本地的
      // 本地数据包含时间安排
      _allBuildings = {};
      for (var building in LoungeDB().db.readBuildingData) {
        _allBuildings[building.id] = building;
      }
      if (_allBuildings.isEmpty) {
        // 如果从本地获取的数据为空，要不是本地没有数据，要么是初始化时有异常
        throw LoungeError.database(
          error,
          stackTrace: stack,
          des: 'BuildingData getBuildingList no local data',
        );
      }
      return <String, Building>{};
    };

    final catchBuildingListDBError = (error, stack) {
      if (error is LoungeError) throw error;
      // 如果获取本地数据也出问题了，就抛出错误，中断加载数据
      _allBuildings = {};
      throw LoungeError.database(
        error,
        stackTrace: stack,
        des: 'BuildingData getBuildingList load local data error',
      );
    };

    await OpenApi.getBaseBuildingList
        .then((data) => _allBuildings = {for (var e in data) e.id: e})
        .catchError(catchBuildingListNetWork)
        .catchError(catchBuildingListDBError);

    // 2. 然后加载一周的教室时间安排
    // 将新的数据复制到内存中，从上面可知 _allBuildings 一定不是空
    final temporaryData = Map.fromIterables(
      List.from(_allBuildings.keys),
      List.generate(_allBuildings.values.length,
          (index) => _allBuildings.values.toList()[index]),
    );

    // 将得到的数据放入临时对象中
    final fillData = (MapEntry<int, List<Building>> plan) {
      for (var building in plan.value) {
        building.iterate(
          (bId, aId, cId, status) {
            temporaryData[bId]!
                .areas[aId]!
                .classrooms[cId]!
                .statuses[plan.key] = status;
          },
          (e, s) => throw LoungeError.network(
            e,
            stackTrace: s,
            des: "BuildingData getRoomsPlan iterate network data error",
          ),
        );
      }
    };

    final catchClassPlanNetWork = (error, stack) {
      if (error is LoungeError) throw error;
      throw LoungeError.network(
        error,
        stackTrace: stack,
        des: "BuildingData getRoomsPlan get network data error",
      );
    };

    // 获取一周的数据
    await OpenApi.getWeekClassPlan(time)
        .listen(fillData, cancelOnError: true)
        .asFuture()
        .catchError(catchClassPlanNetWork);

    // 更新数据
    for (final entry in temporaryData.entries) {
      _allBuildings[entry.key] = entry.value;
    }
  }

  Future<void> getRoomsPlan(DateTime dateTime) async {}

  /// 从所有数据中查询指定教室的时间安排，没找到的话就返回空数据
  Classroom getClassroom(Classroom room) {
    final result = buildings[room.bId]?.areas[room.aId]?.classrooms[room.id];
    return result ?? Classroom.empty();
  }

  /// 查找匹配的教学楼 / 区域 / 教室
  Stream<SearchResult> search(String query) async* {
    yield* querySearch(query, buildings);
  }
}
