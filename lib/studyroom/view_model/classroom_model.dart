

import 'package:wei_pei_yang_demo/studyroom/model/area.dart';
import 'package:wei_pei_yang_demo/studyroom/model/classroom.dart';
import 'package:wei_pei_yang_demo/studyroom/model/time.dart';
import 'package:wei_pei_yang_demo/studyroom/provider/view_state_refresh_list_model.dart';
import 'package:wei_pei_yang_demo/studyroom/service/data.dart';
import 'package:wei_pei_yang_demo/studyroom/service/hive_manager.dart';
import 'package:wei_pei_yang_demo/studyroom/service/studyroom_repository.dart';
import 'package:wei_pei_yang_demo/studyroom/view_model/schedule_model.dart';

class ClassroomsDataModel extends ViewStateRefreshListModel {
  ClassroomsDataModel({this.scheduleModel});

  ScheduleModel scheduleModel;
  String _id;
  int get currentDay => scheduleModel.currentDay;
  Schedule get schedule => scheduleModel.schedule;


  Area _area = Area();
  Area get area => _area;
  Map<String, List<Classroom>> _floors = {};
  Map<String, Map<String, String>> _classPlan = {};

  Map<String, List<Classroom>> get floors => _floors;

  Map<String, Map<String, String>> get classPlan => _classPlan;

  setBaseData(Area data, String id) {
    _area = data;
    _id = id;
    _area.classrooms.forEach((c) {
      var floor = c.name[0];
      var room = Classroom()
        ..name = _area.area_id == null ? c.name : _area.area_id + c.name
        ..capacity = c.capacity
        ..id = c.id;
      if (_floors.containsKey(floor)) {
        print(_floors[floor]);
        var list = List<Classroom>()
          ..addAll(_floors[floor])
          ..add(room);
        _floors[floor] = list;
      } else {
        _floors[floor] = [room];
      }
      print(c.toJson());
      print(floors);

      if (_classPlan.containsKey(c.id)) {
        print('classrooms have same id:' + c.id);
      } else {
        _classPlan[c.id] = {};
      }
    });
  }

  @override
  Future<List> loadData() async {
    var result = await StudyRoomRepository.getWeekClassPlan();

    var t1 = DateTime.now().millisecondsSinceEpoch;
    var instance = await HiveManager.instance;
    var box = instance.buildingBoxes[_id];

    for (int i = 0; i < 7; i++) {
      var buildings = Data.getOneDayAvailable(i);
      await instance.addClassroomsPlan(buildings, i);
    }

    for (var day in Time.week) {
      var b = await box.get(day);
      print(box.keys);
      for (var area in b.areas) {
        if (area.area_id == _area.area_id) {
          area.classrooms.forEach((c) {
            var plan = _classPlan[c.id];
            plan[day] = c.status;
            _classPlan[c.id] = plan;
          });
        }
      }
      var t2 = DateTime.now().millisecondsSinceEpoch;
      print(
          'format $day data finish, use milliseconds :' + (t2 - t1).toString());
    }

    return result;
  }
}
