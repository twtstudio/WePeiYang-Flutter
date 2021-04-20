import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:wei_pei_yang_demo/lounge/service/data_factory.dart';
import 'package:wei_pei_yang_demo/lounge/service/repository.dart';
import 'package:wei_pei_yang_demo/lounge/service/time_factory.dart';
import 'package:wei_pei_yang_demo/lounge/model/area.dart';
import 'package:wei_pei_yang_demo/lounge/model/building.dart';
import 'package:wei_pei_yang_demo/lounge/model/classroom.dart';
import 'package:wei_pei_yang_demo/lounge/model/local_entry.dart';
import 'package:wei_pei_yang_demo/lounge/model/search_entry.dart';
import 'package:wei_pei_yang_demo/lounge/model/temporary.dart';

/// key of [HiveManager._boxesKeys]
const boxes = 'boxesKeys';

/// key of base room plan in every building
const baseRoom = 'baseClassrooms';

/// key of search history
const history = 'history';

/// key of [HiveManager._favourList]
const favourList = 'favourList';

/// key of [HiveManager._temporaryData]
const temporary = 'temporary';

// TODO: 数据库错误处理正在做！！！！！！！！！！！！！！！！！！！！！
class HiveManager {
  static HiveManager _instance;

  // 确保只跑一次
  static final initHiveMemoizer = AsyncMemoizer<HiveManager>();

  Box<LocalEntry> _boxesKeys;

  /// [_temporaryData] 保存非本周临时数据。
  /// 每次更改[LoungeTimeModel.dateTime]时，会先判断是不是这周的时间，不是这周的话：
  /// 1. 通过网络请求请求到那一周的数据，
  /// 2. 在[_temporaryData]中，临时保存这一周的数据[setTemporaryData]，
  /// 3. 在绘制UI时为避免多次网络请求重复加载，会调用[getTemporaryData],
  /// 4. 在每次初始化应用,关闭应用时，以及[setTemporaryData]时，都会清空[clearTemporaryData]
  Box<Buildings> _temporaryData;
  DateTime _temporaryDateTime;

  Box<Classroom> _favourList;

  Box<String> _searchHistory;

  final Map<String, LazyBox<Building>> _buildingBoxes = {};
  final Map<String, String> _buildingName = {};

  static init() async {
    _instance = await initHiveMemoizer.runOnce(() async {
      await Hive.initFlutter();
      Hive.registerAdapter<LocalEntry>(LocalEntryAdapter());
      Hive.registerAdapter<Building>(BuildingAdapter());
      Hive.registerAdapter<Area>(AreaAdapter());
      Hive.registerAdapter<Classroom>(ClassroomAdapter());
      Hive.registerAdapter<Buildings>(BuildingsAdapter());
      _instance = HiveManager();
      _instance._temporaryData = await Hive.openBox<Buildings>(temporary);
      _instance._boxesKeys = await Hive.openBox<LocalEntry>(boxes);
      _instance._favourList = await Hive.openBox<Classroom>(favourList);
      // print('_favourList init finish');
      for (var key in _instance._boxesKeys.keys) {
        var e = await Hive.boxExists(key);
        if (e) {
          _instance._buildingBoxes[key] = await Hive.openLazyBox<Building>(key);
        } else {
          // print('box disappear:' + key);
        }
      }
      return _instance;
    });
    // print('hive init finish');
  }

  static HiveManager get instance {
    if (_instance == null) {
      throw Exception('HiveManager _instance == null');
    }
    return _instance;
  }

  /// 将非本周数据保存到[_temporaryData]中
  setTemporaryData({
    @required List<Building> data,
    @required int day,
  }) async {
    await _temporaryData.put(Time.week[day - 1], Buildings(buildings: data));
  }

  setTemporaryDataStart() async {
    await _temporaryData.delete(temporary);
  }

  setTemporaryDataFinish(DateTime dateTime) async {
    await _temporaryData.put(temporary, null);
    _temporaryDateTime = dateTime;
    CommonPreferences().temporaryUpdateTime.value = dateTime.toString();
  }

  clearTemporaryData() async => await _temporaryData.clear();

  Future<Classroom> addFavourite({String id, Classroom clearRoom}) async {
    // print(_favourList.keys.toList());
    if (clearRoom == null) {
      Classroom room;
      try {
        room = await findRoomPathById(id: id);
        await _favourList.put(room.id, room);
      } on StateError catch (e) {
        throw e;
      } catch (e) {
        throw e;
      }
      return room;
    } else {
      await _favourList.put(clearRoom.id, clearRoom);
      return null;
    }
  }

  Future<Classroom> findRoomPathById({String id}) async {
    List<Classroom> rCs = [];
    await baseBuildingDataFromDisk.forEach(
      (building) => building.areas.values.forEach(
        (area) => rCs.addAll(
          area.classrooms.values
              .where((room) => room.id == id)
              .map((room) => room..bId = building.id),
        ),
      ),
    );
    for (var r in rCs) {
      debugPrint(r.toJson().toString());
    }
    assert(rCs.length == 1);
    return rCs.first;
  }

  initBuildingName([bool first]) async {
    debugPrint("initBuildingName");
    if (_boxesKeys.isNotEmpty && !shouldUpdateLocalData) {
      for (var id in _boxesKeys.keys) {
        var building = await _buildingBoxes[id].get(baseRoom);
        _buildingName[id] = building.name;
        print("building name : ${building.name}");
      }
    } else if (shouldUpdateLocalData) {
      try {
        await LoungeRepository.updateLocalData(DateTime.now());
        await initBuildingName(false);
      } catch (e) {
        ToastProvider.error(e.toString().split(':')[1].trim());
        debugPrint("initBuildingName retry error ${e.toString()}");
        throw e;
      }
    }
  }

  String getBuildingNameById(String id) => _boxesKeys.get(id)?.name ?? "不知道";

  removeFavourite({String cId}) async {
    await _favourList.delete(cId);
  }

  replaceFavourite({List<Classroom> list}) async {
    await Hive.deleteBoxFromDisk(favourList);
    _favourList = await Hive.openBox<Classroom>(favourList);
    for (var room in list) {
      await addFavourite(id: room.id);
    }
  }

  Future<Map<String, Classroom>> getFavourList() async {
    if (_favourList == null) {
      throw Exception("_favourList doesn't init");
    }
    return _favourList.toMap().cast<String, Classroom>();
  }

  bool get shouldUpdateLocalData => _boxesKeys.isEmpty
      ? true
      : !_boxesKeys.values.map((e) {
          print(e?.dateTime ?? "no date time error");
          return e == null ? false : DateTime.parse(e?.dateTime ?? '').isToday;
        }).reduce((v, e) => v && e);

  bool shouldUpdateTemporaryData({@required DateTime dateTime}) {
    debugPrint("shouldUpdateTemporaryData ${_temporaryDateTime.toString()}");
    if (_temporaryDateTime == null) {
      _temporaryDateTime = dateTime;
      CommonPreferences().temporaryUpdateTime.value = dateTime.toString();
      return true;
    } else {
      if (_temporaryDateTime.isTheSameWeek(dateTime) &&
          _temporaryData.containsKey(temporary)) {
        return false;
      } else {
        return true;
      }
    }
  }

  Stream<Building> get baseBuildingDataFromDisk async* {
    // print(_boxesKeys.keys.toList());
    debugPrint(
        'baseBuildingDataFromDisk :' + _boxesKeys.keys.toList().toString());
    for (var key in _boxesKeys.keys) {
      if (_buildingBoxes.containsKey(key)) {
        var building = await _buildingBoxes[key].get(baseRoom);
        yield building;
      } else {
        throw Exception('box not exist : $key');
      }
    }
  }

  /// 从网路获取这教学楼基础数据数据后，将数据写入本地文件
  writeBaseDataInDisk({@required List<Building> buildings}) async {
    for (var building in buildings) {
      await _writeInBox(building);
    }
  }

  _writeInBox(Building building) async {
    var id = building.id;
    print(id);
    if (_boxesKeys.values.contains(id)) {
      // print('building exist:' + id);
    } else {
      var box = await Hive.openLazyBox<Building>(id);
      await box.put(baseRoom, building);
      _buildingBoxes[id] = box;
      // print('box created finish :' + id);
      // print(box.path);
      await _boxesKeys.put(building.id, null);
      _buildingName[id] = building.name;
      print("building name : ${building.name}");
    }
  }

  /// 从网路获取本周课程安排数据后，将数据写入本地文件，并更新时间信息
  writeThisWeekDataInDisk(
    List<Building> buildings,
    int day,
  ) async {
    print('writedataindisk !!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    for (var building in buildings) {
      print('writedataindisk !!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      await _writeThisWeekData(building, day);
    }
  }

  /// 根据日期先判断时星期几，然后设置那天的教室安排
  _writeThisWeekData(Building building, int day) async {
    var key = Time.week[day - 1];
    // TODO: 错误处理
    if (_buildingBoxes.containsKey(building.id)) {
      var box = _buildingBoxes[building.id];
      if (box.containsKey(key)) {
        await box.delete(key);
      }
      await box.put(key, building);
      await _setBuildingDataRefreshTime(building.id, building.name);
    } else {
      // print('box not exist :' + building.id);
    }
  }

  /// 记录最重要的本周数据的获取时间，以判断是否需要刷新数据
  _setBuildingDataRefreshTime(String id, String name) async =>
      await _boxesKeys.put(id, LocalEntry(id, name, DateTime.now().toString()));

  clearLocalData() async {
    for (var box in _buildingBoxes.values) {
      await box.clear();
    }
    await _boxesKeys.clear();
  }

  checkBaseDataIsAllInDisk() async {
    if (shouldUpdateLocalData) {
      throw Exception('我也不知道为什么更新的数据不是今天的');
    }
  }

  //TODO: 没有做错误处理
  Future<Map<String, List<String>>> getRoomPlans(
      {@required Classroom r, @required DateTime dateTime}) async {
    Map<String, List<String>> _plans = {};
    var id = r.bId;
    // print('get class plans id: ' + id);
    debugPrint("getRoomPlans ${r.id} ${dateTime.toString()}");
    await getBuildingPlanData(id: id, time: dateTime).forEach((plan) {
      var day = plan.key;
      var building = plan.value;
      _plans[day] = ['11', '11', '11', '11', '11', '11'];
      var area = building.areas[r.aId];
      if (area == null) return;
      var room = area.classrooms[r.id];
      if (room == null) return;
      _plans[day] = DataFactory.splitPlan(room.status);
      // print('???????????splitplan');
      // print( DataFactory.splitPlan(room.status));
    });
    return _plans;
  }

  Stream<MapEntry<String, Building>> getBuildingPlanData(
      {String id, DateTime time}) async* {
    if (time.isThisWeek) {
      if (_buildingBoxes.containsKey(id) && _boxesKeys.keys.contains(id)) {
        var box = _buildingBoxes[id];
        for (var day in Time.week) {
          var data = await box.get(day);
          yield MapEntry(day, data);
        }
      } else {
        throw Exception('get data from box error: ' + id);
      }
    } else {
      var updateTime = DateTime.tryParse(
        CommonPreferences().temporaryUpdateTime.value,
      );

      var ifNotUpdate = updateTime?.isTheSameWeek(time) ?? false;

      if (_temporaryData.isEmpty || !ifNotUpdate) {
        await LoungeRepository.updateTemporaryData(time);
      }

      for (var day in Time.week) {
        var data = _temporaryData.get(day);
        for (var building in data.buildings) {
          if (building.id == id) {
            yield MapEntry(day, building);
            break;
          }
        }
      }
    }
  }

  Future<List<String>> get searchHistory async {
    _searchHistory = await Hive.openBox<String>(history);
    return _searchHistory.values.toList();
  }

  Stream<ResultEntry> search(Map<String, String> formatQueries) async* {
    // 区域作为辅助查找条件
    var aName = formatQueries['aName'];
    var bName = formatQueries['bName'];
    var cName = formatQueries['cName'];

    List<LocalEntry> rBs = bName != null
        ? _boxesKeys.values.where((b) => b.name.startsWith(bName)).toList()
        : [];

    var hasA = aName != null;
    var hasB = bName != null ? true : rBs.isNotEmpty;
    var hasC = cName != null;
    print('formatQueries');
    print(formatQueries);
    print('$aName   $bName   $cName   $hasA   $hasB   $hasC');

    if (hasB) {
      for (var b in rBs) {
        var building = await _buildingBoxes[b.key].get(baseRoom);
        if (hasC) {
          // 教学楼  + 教室   首先找到教学楼， 再找到教室
          // 如果教室的name format 出来时40 那么可能匹配到多间教室
          // 44 D 301 应该是可以到 44 A 301
          for (var area in building.areas.entries) {
            for (var room in area.value.classrooms.values) {
              if (room.name.startsWith(cName))
                yield ResultEntry(
                    building: building, area: area.value, room: room);
            }
          }
        } else {
          // 没有教室   找到该教学楼
          if (hasA) {
            // 还有区域   找到该区域  按照教学楼 + 区域展示
            for (var a in building.areas.entries) {
              if (a.value.id == aName) {
                yield ResultEntry(building: building, area: a.value);
                break;
              }
            }
          } else {
            // 只有教学楼   展示教学楼
            yield ResultEntry(building: building);
          }
        }
      }
    } else {
      if (hasC) {
        if (hasA) {
          // 区域 + 教室
          List<MapEntry<Building, Classroom>> rCs = [];
          await baseBuildingDataFromDisk.forEach((building) => building
              .areas.values
              .where((element) => element.id == aName)
              .forEach((e) => rCs.addAll(e.classrooms.values
                  .where((element) => element.name == cName)
                  .map((e) => MapEntry(building, e)))));
          for (var r in rCs) {
            yield ResultEntry(
              building: r.key,
              area: Area(id: aName),
              room: r.value,
            );
          }
        } else {
          // 只有教室
          List<MapEntry<Building, Classroom>> rCs = [];
          await baseBuildingDataFromDisk.forEach((building) => building
              .areas.values
              .forEach((e) => rCs.addAll(e.classrooms.values
                  .where((element) => element.name == cName)
                  .map((e) => MapEntry(building, e)))));
          for (var r in rCs) {
            // print(r.value.toJson());
            yield ResultEntry(
              building: r.key,
              area: Area(id: r.value.aId),
              room: r.value,
            );
          }
        }
      } else {
        if (hasA) {
          // 只有区域   找到包含该区域的教学楼  按照教学楼 + 区域展示
          List<Building> tBs = [];
          await baseBuildingDataFromDisk.forEach((building) {
            if (building.areas.values
                .where((element) => element.id == aName)
                .isNotEmpty) tBs.add(building);
          });
          for (var b in tBs) {
            yield ResultEntry(
              building: b,
              area: b.areas[aName],
            );
          }
        } else {
          // format 不出来
        }
      }
    }
  }

  clearHistory() async => await _searchHistory.clear();

  addSearchHistory({@required String query}) async {
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

  /// 删除自习室的所有数据
  clearLoungeDataInDisk() {
    clearLocalData();
    clearTemporaryData();
    clearHistory();
  }

  closeBoxes() async {
    await Hive.close();
  }
}
