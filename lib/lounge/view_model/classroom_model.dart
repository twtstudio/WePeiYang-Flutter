import 'package:wei_pei_yang_demo/lounge/model/area.dart';
import 'package:wei_pei_yang_demo/lounge/model/classroom.dart';
import 'package:wei_pei_yang_demo/lounge/provider/view_state_list_model.dart';
import 'package:wei_pei_yang_demo/lounge/service/data.dart';
import 'package:wei_pei_yang_demo/lounge/service/hive_manager.dart';
import 'package:wei_pei_yang_demo/lounge/service/time_factory.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/sr_time_model.dart';

class ClassroomsDataModel extends ViewStateListModel {
  ClassroomsDataModel._(
      this.id, this.area, this.scheduleModel, this.classPlan, this.floors) {
    this.scheduleModel.addListener(() {
      refresh();
    });
  }

  factory ClassroomsDataModel(String id, Area area, SRTimeModel srTimeModel) {
    final Map<String, Map<String, String>> classPlan = {};
    final Map<String, List<Classroom>> floors = {};
    for (var c in area.classrooms.values) {
      var floor = c.name[0];
      var room = Classroom()
        ..name = area.area_id == '' ? c.name : area.area_id + c.name
        ..capacity = c.capacity
        ..id = c.id;
      if (floors.containsKey(floor)) {
        var list = List<Classroom>()
          ..addAll(floors[floor])
          ..add(room);
        floors[floor] = list;
      } else {
        floors[floor] = [room];
      }
      print(c.toJson());
      print(floors);
      if (classPlan.containsKey(c.id)) {
        print('classrooms have same id:' + c.id);
      } else {
        classPlan[c.id] = {};
      }
    }
    return ClassroomsDataModel._(id, area, srTimeModel, classPlan, floors);
  }

  final SRTimeModel scheduleModel;
  final Area area;

  final String id;
  final Map<String, Map<String, String>> classPlan;
  final Map<String, List<Classroom>> floors;

  int get currentDay => scheduleModel.dateTime.weekday;

  List<Schedule> get schedule => scheduleModel.schedule;

  @override
  Future<List> loadData() async {
    Map<String, Map<String, String>> _plan = Map.from(classPlan)
        .map((key, value) => MapEntry(key, Map<String, String>()));

    // TODO: 这个错误怎么判断啊？
    await HiveManager.instance
        .getBuildingPlanData(id: id, time: scheduleModel.dateTime)
        .forEach((plan) {
      var building = plan.value;
      var day = plan.key;
      var ab = building.areas[area.area_id];
      if (ab == null) return;
      for (var c in ab.classrooms.values) {
        _plan[c.id].putIfAbsent(day, () => c.status ?? '');
      }
    });
    for (var key in _plan.keys) {
      classPlan.update(key, (value) => _plan[key]);
    }

    return Data.getOneDayAvailable(scheduleModel.dateTime.weekday);
  }
}
