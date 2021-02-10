import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wei_pei_yang_demo/studyroom/model/area.dart';
import 'package:wei_pei_yang_demo/studyroom/model/building.dart';
import 'package:wei_pei_yang_demo/studyroom/model/classroom.dart';
import 'package:wei_pei_yang_demo/studyroom/model/key.dart';
import 'package:wei_pei_yang_demo/studyroom/model/search_history.dart';
import 'package:wei_pei_yang_demo/studyroom/model/time.dart';

const boxes = 'boxesKeys';
const baseRoom = 'baseClassrooms';
const searchHistory = 'history';

/// 考虑在每次init HiveManager 的时候就请求数据
/// 每次直接请求这一周的数据，存在数据库里
/// 如果要查询这周以外的数据，请求服务器
/// 考虑到数据可能发生变化，所以我认为应该在boxesKeys中添加一个值，
///   来判断是否应该请求这一周的数据
/// DBState : 1. bool getDataIsFinished  2. String updateTime
/// 每个building是一个box，每个box中有八个key，分别是 baseRoom,
///   monday,tuesday,wednesday,thursday,friday,saturday,sunday,
///   来存储每个building的所有教室，和每天有空闲的教室

const notReady = false;
const ready = true;

class HiveManager {
  static HiveManager _instance;

  Box<Key> boxesKeys;

  Map<String, LazyBox<Building>> buildingBoxes = {};

  static Future<void> install() async => Hive.initFlutter();

  static Future<HiveManager> get instance async {
    if (_instance == null) {
      _instance = HiveManager();
      await Hive.initFlutter();
      Hive.registerAdapter<Key>(KeyAdapter());
      Hive.registerAdapter<DBState>(DBStateAdapter());
      Hive.registerAdapter<Building>(BuildingAdapter());
      Hive.registerAdapter<Area>(AreaAdapter());
      Hive.registerAdapter<Classroom>(ClassroomAdapter());
      Hive.registerAdapter<SearchHistory>(SearchHistoryAdapter());
      _instance.boxesKeys = await Hive.openBox<Key>(boxes);
      // _instance.boxesKeys.put('1',Key('1'));

      var values = _instance.boxesKeys.values;
      // print(values.runtimeType);
      // for(Key k in values){
      //   print(k.runtimeType);
      // }
      print(values);
      for (var k in _instance.boxesKeys.values) {
        var key = k.key;
        var e = await Hive.boxExists(key);
        if (e) {
          var box = await Hive.openLazyBox<Building>(key);
          _instance.buildingBoxes[key] = box;
          print('box :' + box.name);
        } else {
          print('box disappear:' + key);
        }
      }
    }
    return _instance;
  }

  Future<void> changeDataState(String id, bool state) {
    boxesKeys.delete(id);
    boxesKeys.put(id, Key(id, DBState(state, DateTime.now().toString())));
  }

  Future<void> createBox(Building building) async {
    var bName = building.id;
    if (boxesKeys.values.contains(bName)) {
      print('building exist:' + bName);
    } else {
      await changeDataState(building.id, notReady);

      var box = await Hive.openLazyBox<Building>(bName);
      await box.put(baseRoom, building);
      buildingBoxes[bName] = box;

      await changeDataState(building.id, ready);
      print('box created finish :' + bName);
      print(box.path);
    }
  }

  Future<void> createBuildingBoxes(List<Building> buildings) async {
    var t1 = DateTime.now().millisecond;
    for (var building in buildings) {
      await createBox(building);
    }
    var t2 = DateTime.now().millisecond;
    print('use time:' + (t2 - t1).toString());
  }

  /// 0 ... 6
  Future<void> addClassroomsPlan(
    List<Building> buildings,
    int day,
  ) async {
    for (var building in buildings) {
      await putData(building, day);
    }
  }

  Future<void> clearClassroomPlan() {
    for (var box in buildingBoxes.values) {
      Time.week.forEach((day) async {
        await box.delete(day);
      });
    }
  }

  /// 根据日期先判断时星期几，然后设置那天的教室安排
  Future<void> putData(Building building, int day) async {
    var key = Time.week[day];

    if (boxesKeys.keys.contains(building.id)) {
      if (buildingBoxes.containsKey(building.id)) {
        var box = buildingBoxes[building.id];
        if (box.containsKey(key)) {
          await box.delete(key);
        }
        await box.put(key, building);
        print('!!!!!!!!!!!!!!!!!!!!put data finished :' +
            building.toJson().toString());
      }
    } else {
      print('box not exist :' + building.id);
    }
  }

  Future<Building> getData(String id) async {
    if (buildingBoxes.containsKey(id) && boxesKeys.values.contains(id)) {
      var box = buildingBoxes[id];
      var data = await box.get(id);
      return data;
    } else {
      print('get data from box error: ' + id);
      return Building();
    }
  }

  static Future<List<SearchHistory>> getSearchHistory() async {
    print('get search history');
    var box = await Hive.openBox<SearchHistory>(searchHistory);
    print('get search history2');
    await box.put(1, SearchHistory('44', '101', 'A', '1', '00', '123123'));
    await box.put(2, SearchHistory('45', '102', '', '2', '13', '123123'));
    await box.put(3, SearchHistory('35', '101', 'A', '3', '15', '123123'));
    var history = box.values;
    print(history.toString());
    return history.toList();
  }

  Future<void> closeBoxes() async {
    // await Hive.close();
    // _instance = null;
    // boxesKeys = null;
    // buildingBoxes= {};
  }
}
