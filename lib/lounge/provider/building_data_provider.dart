// @dart = 2.12

import 'package:flutter/cupertino.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/lounge/provider/config_provider.dart';
import 'package:we_pei_yang_flutter/lounge/server/hive_manager.dart';
import 'package:we_pei_yang_flutter/lounge/server/repository.dart';
import 'package:we_pei_yang_flutter/lounge/server/search_server.dart';
import 'package:we_pei_yang_flutter/lounge/model/building.dart';
import 'package:we_pei_yang_flutter/lounge/model/classroom.dart';

import 'load_state_notifier.dart';

class BuildingData extends LoadStateChangeNotifier {
  BuildingData() {
    _updateTime = DateTime.tryParse(CommonPreferences().loungeUpdateTime.value);
    _allBuildings = {};
  }

  // 数据刷新时间
  DateTime? _updateTime;

  DateTime? get updateTime => _updateTime;

  set updateTime(DateTime? time) {
    if (time != null) {
      CommonPreferences().loungeUpdateTime.value = time.toString();
      _updateTime = time;
    }
  }

  // 所有教学楼数据
  late Map<String, Building> _allBuildings;

  Map<String, Building> get buildings => _allBuildings;

  /// 卫津路的教学楼
  List<Building> get wjl {
    return buildings.values
        .where(
          (b) => b.campus == Campus.wjl.id,
        )
        .toList();
  }

  /// 北洋园的教学楼
  List<Building> get byy {
    return buildings.values
        .where(
          (b) => b.campus == Campus.byy.id,
        )
        .toList();
  }

  /// 刷新指定日期的那周的数据
  Future<void> getDataOfWeek(DateTime time) async {
    stateRefreshing();
    await getBuildingList();
    await getRoomsPlan(time);
    stateSuccess();
  }

  /// 初始化数据
  Future<void> initData() async {
    stateRefreshing();
    await getBuildingList();
    await getRoomsPlan(DateTime.now());
    stateSuccess();
  }

  /// 加载教学楼数据（无教室占用信息）。
  /// 如果成功加载服务器数据，则更新ui，并刷新本地数据库；
  /// 如果没有获得新的数据（网络错误或解析错误），则显示一个提醒（TODO）
  Future<void> getBuildingList() async {
    try {
      final data = await Repository.getBaseBuildingList;
      _allBuildings = {for (var e in data) e.id: e};
      LoungeDB().checkAndWriteBuildingBaseData(data);
    } catch (_) {
      _allBuildings = {};
      await for (var building in LoungeDB().db.readBuildingData) {
        _allBuildings[building.id] = building;
      }
      // TODO: 显示一个错误提醒
    }
  }

  /// 加载一周的教室时间安排
  Future<void> getRoomsPlan(DateTime dateTime) async {
    // 将新的数据复制到内存中
    await for (var getDayPlan in Repository.getWeekClassPlan(dateTime)) {
      final plan = await getDayPlan;
      for (var building in plan.value) {
        for (var area in building.areas.entries) {
          for (var room in area.value.classrooms.entries) {
            _allBuildings[building.id]!
                .areas[area.key]!
                .classrooms[room.key]!
                .statuses[plan.key] = room.value.status;
          }
        }
      }
    }

    // 设置本次更新时间
    updateTime = dateTime;

    // for (var building in _allBuildings!.values) {
    //   debugPrint('$building');
    // }

    debugPrint('get new plan data');

    // 通知ui刷新
    notifyListeners();

    // 将新的数据写入本地数据库
    LoungeDB().db.writeRoomPlan(_allBuildings, dateTime);
  }

  Classroom? getClassroom(Classroom room) {
    return buildings[room.bId]?.areas[room.aId]?.classrooms[room.id];
  }

  Stream<SearchResult> search(String query) async* {
    yield* querySearch(query, buildings);
  }
}
