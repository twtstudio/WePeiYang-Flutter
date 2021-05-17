import 'package:flutter/foundation.dart';
import 'package:wei_pei_yang_demo/lounge/model/area.dart';
import 'package:wei_pei_yang_demo/lounge/model/classroom.dart';
import 'package:wei_pei_yang_demo/lounge/provider/view_state_model.dart';
import 'package:wei_pei_yang_demo/lounge/service/hive_manager.dart';
import 'package:wei_pei_yang_demo/lounge/service/time_factory.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/lounge_time_model.dart';

class ClassroomsDataModel extends ViewStateListModel {
  ClassroomsDataModel(this.id, this.area, this.timeModel) {
    timeModel.addListener(refresh);
  }

  final LoungeTimeModel timeModel;
  final Area area;
  final String id;
  final Map<String, Map<String, String>> classPlan = {};
  final Map<String, List<Classroom>> floors = {};

  int get currentDay => timeModel.dateTime.weekday;

  List<ClassTime> get classTime => timeModel.classTime;

  @override
  initData() {
    setBusy();
    Map<String, List<Classroom>> f = {};
    for (var c in area.classrooms.values) {
      var floor = c.name[0];
      var room = c..aId = area.id;
      if (f.containsKey(floor)) {
        var list = List<Classroom>()
          ..addAll(f[floor])
          ..add(room);
        f[floor] = list;
      } else {
        f[floor] = [room];
      }
      // print(c.toJson());
      // print(floors);
      if (classPlan.containsKey(c.id)) {
        print('classrooms have same id:' + c.id);
      } else {
        classPlan[c.id] = {};
      }
    }
    floors.addAll(f.sortByFloor);
    super.initData();
  }

  @override
  refresh() async {
    setBusy();
    if (timeModel.state == ViewState.error) {
      setError(Exception('refresh data error when change date'), null);
    } else if (timeModel.state == ViewState.idle) {
      debugPrint('++++++++++++++++ class plan model get data +++++++++++++++++++');
      super.refresh();
    }
  }

  @override
  Future<List> loadData() async {
    // await Future.delayed(Duration(seconds: 1));
    Map<String, Map<String, String>> _plan = Map.from(classPlan)
        .map((key, value) => MapEntry(key, Map<String, String>()));

    await HiveManager.instance
        .getBuildingPlanData(id: id, time: timeModel.dateTime)
        .forEach((plan) {
      var building = plan.value;
      var day = plan.key;
      var ab = building.areas[area.id];
      if (ab == null) return;
      for (var c in ab.classrooms.values) {
        _plan[c.id].putIfAbsent(day, () => c.status ?? '');
      }
    });
    for (var key in _plan.keys) {
      classPlan.update(key, (value) => _plan[key]);
    }

    return _plan.keys.toList();
  }
}

extension MapExtension on Map {
  Map<String, List<Classroom>> get sortByFloor {
    List<String> list = keys.toList();
    list.sort((a, b) => a.compareTo(b));
    return Map.fromEntries(list.map((e) {
      List<Classroom> cList = this[e];
      cList.sort((a, b) => a.name.compareTo(b.name));
      return MapEntry(e, cList);
    }));
  }
}
