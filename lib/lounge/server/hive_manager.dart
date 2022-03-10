// @dart = 2.12

import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:we_pei_yang_flutter/lounge/model/area.dart';
import 'package:we_pei_yang_flutter/lounge/model/building.dart';
import 'package:we_pei_yang_flutter/lounge/model/classroom.dart';
import 'package:we_pei_yang_flutter/lounge/model/local_entry.dart';
import 'package:we_pei_yang_flutter/lounge/model/temporary.dart';
import 'package:we_pei_yang_flutter/lounge/util/data_util.dart';
import 'package:we_pei_yang_flutter/lounge/util/time_util.dart';

/// key of [HiveManager._boxesKeys]
const boxes = 'boxesKeys';

/// key of base room plan in every building
const baseRoom = 'baseClassrooms';

/// key of search history
const history = 'history';

/// key of [HiveManager._favourList]
const favours = 'favourList';

/// key of [HiveManager._temporaryData]
const temporary = 'temporary';

class LoungeDB {
  LoungeDB._();

  static final _instance = LoungeDB._();

  factory LoungeDB() => _instance;

  // 使用多态有错误提示 。。。 但实际上没问题，先这么写吧
  // 我感觉是编译器的问题
  final db = HiveManager();

  static Future<void> initDB() async {
    await _instance.db.init();
  }

  static Future<void> closeDB() async {
    await Hive.close();
  }

  Future<void> checkAndWriteBuildingBaseData(List<Building> data) async {
    if (db.shouldUpdateLocalData) {
      await db.writeBuildingData(data).catchError((e) {
        debugPrint('quietly throw writeBuildingData error $e');
      });
    }
  }
}

abstract class LoungeDataBase {
  @protected
  Future<void> init();

  @protected
  Future<void> writeBuildingData(List<Building> buildings);

  @protected
  Future<void> writeRoomPlan(Map<String, Building> buildings, DateTime time);

  @protected
  Future<Map<int, List<String>>> readRoomPlan({
    required Classroom room,
    required DateTime dateTime,
  });

  @protected
  Stream<Building> get readBuildingData;

  @protected
  Future<Classroom?> findRoomById(String rId);

  @protected
  Future<void> removeFavourite(String cId);

  @protected
  Future<void> updateFavourites(List<Classroom> list);

  @protected
  Future<Classroom?> addFavourite({Classroom? room, String? id});

  @protected
  Future<void> replaceFavourite(List<Classroom> list);

  @protected
  Future<Map<String, Classroom>> get favourList;

  @protected
  Future<List<String>> get searchHistory;

  @protected
  Future<void> clearHistory();

  @protected
  Future<void> addSearchHistory(String query);

  @protected
  Stream search(Map<String, String> formatQueries);

  @protected
  bool get shouldUpdateLocalData;
}

// 用 Hive的原因主要是跨平台
class HiveManager extends LoungeDataBase {
  late Box<LocalEntry> _boxesKeys;

  late Box<Classroom> _favourList;

  late Box<String> _searchHistory;

  final Map<String, LazyBox<Building>> _buildingBoxes = {};

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter<LocalEntry>(LocalEntryAdapter());
    Hive.registerAdapter<Building>(BuildingAdapter());
    Hive.registerAdapter<Area>(AreaAdapter());
    Hive.registerAdapter<Classroom>(ClassroomAdapter());
    Hive.registerAdapter<Buildings>(BuildingsAdapter());
    _boxesKeys = await Hive.openBox<LocalEntry>(boxes);
    _favourList = await Hive.openBox<Classroom>(favours);
    for (var key in _boxesKeys.keys) {
      var e = await Hive.boxExists(key);
      if (e) {
        _buildingBoxes[key] = await Hive.openLazyBox<Building>(key);
      }
    }
  }

  @override
  bool get shouldUpdateLocalData => _boxesKeys.isEmpty
      ? true
      : !_boxesKeys.values.map((e) {
          bool isToday;
          try {
            isToday = e.dateTime == ''
                ? false
                : Time.checkDateTimeAvailable(DateTime.parse(e.dateTime))
                    .isToday;
          } catch (e) {
            isToday = false;
          }
          return isToday;
        }).reduce((v, e) => v && e);

  DateTime? get localDateLastUpdateTime => _boxesKeys.isEmpty
      ? null
      : DateTime.tryParse(_boxesKeys.values.first.dateTime);

  @override
  Stream<Building> get readBuildingData async* {
    for (var key in _boxesKeys.keys) {
      if (_buildingBoxes.containsKey(key)) {
        var building = await _buildingBoxes[key]!.get(baseRoom);
        yield building!;
      } else {
        throw Exception('box not exist : $key');
      }
    }
  }

  @override
  Future<Map<int, List<String>>> readRoomPlan({
    required Classroom room,
    required DateTime dateTime,
  }) async {
    Map<int, List<String>> _plans = {};

    final buildingBox = _buildingBoxes[room.bId]!;
    final building = await buildingBox.get(baseRoom);
    for (var area in building!.areas.values) {
      for (var _room in area.classrooms.values) {
        if (_room.id == room.id) {
          return _room.statuses.map(
            (key, value) => MapEntry(
              key,
              DataFactory.splitPlan(value),
            ),
          );
        }
      }
    }
    return _plans;
  }

  clearLocalData() async {
    for (var box in _buildingBoxes.values) {
      await box.clear();
    }
    await _boxesKeys.clear();
  }

  @override
  Future<Classroom?> findRoomById(String rId) async {
    await for (var building in readBuildingData) {
      for (var area in building.areas.values) {
        for (var room in area.classrooms.values) {
          if (room.id == rId) {
            return room;
          }
        }
      }
    }
    return null;
  }

  @override
  Future<void> writeBuildingData(List<Building> buildings) async {
    for (var building in buildings) {
      var id = building.id;
      if (_boxesKeys.values.map((e) => e.key).contains(id)) {
        var box = _buildingBoxes[id]!;
        await box.put(baseRoom, building);
        // debugPrint(building.toString());
        // debugPrint('update building $id');
      } else {
        var box = await Hive.openLazyBox<Building>(id);
        await box.put(baseRoom, building);
        _buildingBoxes[id] = box;
        await _setBuildingDataRefreshTime(building.id, building.name, '');
        // debugPrint('write building $id');
      }
    }
  }

  @override
  Future<void> writeRoomPlan(
    Map<String, Building> buildings,
    DateTime time,
  ) async {
    for (var building in buildings.entries) {
      if (_buildingBoxes.containsKey(building.key)) {
        var box = _buildingBoxes[building.key]!;
        if (box.containsKey(building.key)) {
          await box.delete(building.key);
        }
        await box.put(building.key, building.value);
        await _setBuildingDataRefreshTime(
          building.key,
          building.value.name,
          time.toString(),
        );
      } else {
        debugPrint('box not exist :' + building.key);
      }
    }
  }

  /// 记录最重要的本周数据的获取时间，以判断是否需要刷新数据
  _setBuildingDataRefreshTime(String id, String name, String time) async =>
      await _boxesKeys.put(
        id,
        LocalEntry(
          key: id,
          name: name,
          dateTime: time,
        ),
      );

  @override
  Future<void> removeFavourite(String cId) async {
    await _favourList.delete(cId);
  }

  @override
  Future<void> updateFavourites(List<Classroom> list) async {
    await _favourList.clear();
    for (var room in list) {
      await addFavourite(room: room);
    }
  }

  @override
  Future<Classroom?> addFavourite({Classroom? room, String? id}) async {
    final _room = room ?? await findRoomById(id ?? '');
    if (_room != null) {
      await _favourList.put(_room.id, _room);
    }
    return _room;
  }

  @override
  Future<void> replaceFavourite(List<Classroom> list) async {
    _favourList.clear();
    for (var room in list) {
      await addFavourite(room: room);
    }
  }

  @override
  Future<Map<String, Classroom>> get favourList async {
    return _favourList.toMap().cast<String, Classroom>();
  }

  @override
  Future<List<String>> get searchHistory async {
    _searchHistory = await Hive.openBox<String>(history);
    return _searchHistory.values.toList();
  }

  @override
  Future<void> clearHistory() async {
    await _searchHistory.clear();
  }

  @override
  Future<void> addSearchHistory(String query) async {
    if (_searchHistory.values.contains(query)) {
      var key = _searchHistory.values
          .map((element) {
            return element == query ? element : '';
          })
          .toList()
          .asMap()
          .entries
          .firstWhere((element) => element.value == query)
          .key;
      await _searchHistory.deleteAt(key);
    }
    await _searchHistory.put(DateTime.now().toString(), query);
  }

  @override
  Stream search(Map<String, String> formatQueries) async* {}
}
