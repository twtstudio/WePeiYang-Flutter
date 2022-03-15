// @dart = 2.12

import 'package:hive_flutter/hive_flutter.dart';
import 'package:we_pei_yang_flutter/lounge/model/area.dart';
import 'package:we_pei_yang_flutter/lounge/model/building.dart';
import 'package:we_pei_yang_flutter/lounge/model/classroom.dart';
import 'package:we_pei_yang_flutter/lounge/model/favour_entry.dart';
import 'package:we_pei_yang_flutter/lounge/server/error.dart';
import 'package:we_pei_yang_flutter/lounge/util/data_util.dart';

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
}

/// key of [HiveManager._boxesKeys]
const kBoxes = 'boxesKeys';

/// key of [HiveManager._searchHistory]
const kHistory = 'history';

/// key of [HiveManager._favourList]
const kFavours = 'favourList';

/// key of room plan in every building
const kBuilding = 'Classrooms';

// 用 Hive的原因主要是跨平台
class HiveManager {
  /// 收藏
  late Box<FavourEntry> _favourList;

  /// 搜索记录
  late Box<String> _searchHistory;

  /// 教室
  late Box<Building> _buildings;

  Future<void> init() async {
    await Hive.initFlutter('hive_database');
    Hive.registerAdapter<Building>(BuildingAdapter());
    Hive.registerAdapter<Area>(AreaAdapter());
    Hive.registerAdapter<Classroom>(ClassroomAdapter());
    Hive.registerAdapter<FavourEntry>(FavourEntryAdapter());
    _favourList = await Hive.openBox<FavourEntry>(kFavours);
    _buildings = await Hive.openBox<Building>(kBuilding);
    _searchHistory = await Hive.openBox<String>(kHistory);
  }

  /// 获取本地数据
  Iterable<Building> get readBuildingData sync* {
    yield* _buildings.values;
  }

  /// 返回具体一个教室一周的时间安排
  Map<int, List<String>> readRoomPlan({
    required Classroom room,
    required DateTime dateTime,
  }) {
    final building = _buildings.get(room.bId);
    for (var area in building!.areas.values) {
      for (var _room in area.classrooms.values) {
        if (_room.id == room.id) {
          return _room.statuses.map(
            (key, value) => MapEntry(key, DataFactory.splitPlan(value)),
          );
        }
      }
    }
    return {};
  }

  /// 清除本地数据（仅删除教室数据）
  Future<void> clearLocalData() async {
    await _buildings.clear();
  }

  /// 从数据库中查找一个教室
  Classroom? findRoomById(String rId) {
    for (var building in readBuildingData) {
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

  /// 将从服务器获取的教学楼数据写入到本地
  Future<void> writeBuildingData(Iterable<Building> buildings) async {
    try {
      for (var building in buildings) {
        await _buildings.put(building.id, building);
      }
    } catch (e, s) {
      // 如果写入数据库出错，就清空数据库
      _buildings.clear();
      throw LoungeError.database(
        e,
        stackTrace: s,
        des: 'writeBuildingData get error and clear local data',
      );
    }
  }
}

extension FavourExt on HiveManager {
  /// 从服务器获取收藏信息后刷新本地数据
  Future<void> updateFavourites(List<Classroom> list, DateTime time) async {
    await _favourList.clear();
    for (var room in list) {
      await collect(time, room: room);
    }
  }

  /// 取消收藏
  ///
  /// 如果 time != null ,则说明没有同步成功
  Future<void> delete(Classroom room, {DateTime? time}) async {
    if (time == null) {
      // 成功从服务器上删除了这个收藏
      // 那么也从本地删除
      await _favourList.delete(room.id);
    } else {
      // 没有从服务器上删除这个收藏
      // 那么本地存储删除操作
      await _favourList.put(room.id, FavourEntry.delete(room, time));
    }
  }

  /// 添加收藏
  Future<Classroom?> collect(
    DateTime time, {
    Classroom? room,
    String? id,
    bool sync = true,
  }) async {
    final _room = room ?? findRoomById(id ?? '');
    if (_room != null) {
      await _favourList.put(
        _room.id,
        FavourEntry.collect(_room, time, sync: sync),
      );
    }
    return _room;
  }

  /// 从本地获取收藏数据
  Map<String, FavourEntry> get favourList {
    return _favourList.toMap().cast<String, FavourEntry>();
  }
}

extension SearchExt on HiveManager {
  /// 从本地获取搜索历史
  Future<List<String>> get searchHistory async {
    return _searchHistory.values.toList();
  }

  /// 清楚本地历史搜索记录
  Future<void> clearHistory() async {
    await _searchHistory.clear();
  }

  /// 添加搜索记录（先删除一样的记录）
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
}
