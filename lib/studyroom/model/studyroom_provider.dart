// @dart=2.12
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:we_pei_yang_flutter/commons/util/logger.dart';
import 'package:we_pei_yang_flutter/commons/util/time.util.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_campus.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_models.dart';
import 'package:we_pei_yang_flutter/studyroom/model/studyroom_service.dart';
import 'package:we_pei_yang_flutter/studyroom/util/time_util.dart';

List<SingleChildWidget> studyroomProviders = [
  // 需要按照如下顺序排列！
  ChangeNotifierProvider(create: (_) => StudyroomProvider())
];

class StudyroomProvider with ChangeNotifier {
  /// 所有的building
  List<Building> buildings = [];

  /// 卫津路的教学楼
  List<Building> get wjl {
    return buildings
        .where(
          (b) => b.isWjl,
        )
        .toList()
      ..sort((a, b) => a.building?.compareTo(b.building ?? '') ?? 0);
  }

  /// 北洋园的教学楼
  List<Building> get byy {
    return buildings
        .where(
          (b) => b.isByy,
        )
        .toList()
      ..sort((a, b) => a.building?.compareTo(b.building ?? '') ?? 0);
  }

  /// 一周的数据
  Map<int, List<Building>> weekdata = {};

  /// 教室map
  Map<String, Classroom> roomData = {};

  /// 收藏教室
  Map<String, Classroom> favorRooms = {};

  /// 加载完成收藏
  bool favorLoaded = false;

  /// 加载完成楼
  bool buildingsLoaded = false;

  /// 选择时间范围
  ClassTimerange _timeRange = ClassTimerangeExtension.current();

  DateTime _dateTime = DateTime.now();

  DateTime get dateTime => _dateTime;

  ClassTimerange get timeRange => _timeRange;

  setDateTime(DateTime date) async {
    if (!_dateTime.isSameWeek(date)) {
      try {
        await _loadBuildingData(StudyRoomDate.fromDate(date));
      } catch (e, s) {
        Logger.reportError(e, s);
        ToastProvider.error('自习室数据拉取失败');
        return;
      }
    }
    _dateTime = date;
    notifyListeners();
  }

  setTimeRange(ClassTimerange range) {
    _timeRange = range;
    notifyListeners();
  }

  Campus _campus = Campus.wjl.init;

  Campus get campus => _campus;

  CrossFadeState get state => _campus.state;

  changeCampus() {
    _campus = _campus.change;
    notifyListeners();
  }

  /// 初始化数据，默认加载本周的自习室和收藏的状态
  init() async {
    final t = StudyRoomDate.current();
    await _loadBuildingData(t);
    buildingsLoaded = true;
    notifyListeners();
    await _loadFavoriteRooms();
    favorLoaded = true;
    notifyListeners();
  }

  /// 加载本周自习室数据
  _loadBuildingData(StudyRoomDate t) async {
    buildings = await StudyroomService.getClassroomPlanOfDay(t);
    weekdata[t.day] = buildings;
    buildings.forEach((building) {
      building.areas?.forEach((area) {
        area.classrooms?.forEach((room) {
          if (room.classroomId == null) return;
          room.statuses[t.day] = room.status ?? '111111111111';
          room.buildingName = building.name;
          room.areaId = area.id;
          roomData[room.classroomId!] = room;
        });
      });
    });
    notifyListeners();
    Future.sync(() async {
      for (int i = 1; i <= 7; i++) {
        if (i == t.day) continue;
        final week = t.week;
        final buildings = await StudyroomService.getClassroomPlanOfDay(
            StudyRoomDate(week, i));
        weekdata[t.day] = buildings;
        buildings.forEach((building) {
          building.areas?.forEach((area) {
            area.classrooms?.forEach((room) {
              if (room.classroomId == null) return;
              // 如果没有这个教室
              if (!roomData.containsKey(room.classroomId)) {
                room.statuses[t.day] = room.status ?? '111111111111';
                room.buildingName = building.name;
                room.areaId = area.id;
                roomData[room.classroomId!] = room;
              } else
                // 设置statues
                roomData[room.classroomId]!.statuses[i] =
                    room.status ?? '111111111111';
            });
          });
        });
      }
      notifyListeners();
    });
  }

  /// 加载收藏自习室数据
  _loadFavoriteRooms() async {
    final ids = await StudyroomService.getFavouriteIds();
    ids.forEach((element) {
      if (roomData.containsKey(element))
        favorRooms[element] = roomData[element]!;
    });
    notifyListeners();
  }

  /// 更改教室收藏状态
  Future<bool> changeRoomFavor(Classroom room) async {
    if (room.classroomId == null) return true;
    final roomId = room.classroomId!;
    if (favorRooms.containsKey(roomId)) {
      // 如果已经收藏，则取消收藏
      final ok = await StudyroomService.deleteRoom(roomId);
      if (ok) favorRooms.remove(roomId);
      notifyListeners();
      return ok;
    } else {
      // 加入收藏
      final ok = await StudyroomService.collectRoom(roomId);
      if (ok) favorRooms[roomId] = room;
      notifyListeners();
      return ok;
    }
  }
}
