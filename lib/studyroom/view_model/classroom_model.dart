import 'package:wei_pei_yang_demo/studyroom/model/area.dart';
import 'package:wei_pei_yang_demo/studyroom/model/classroom.dart';
import 'package:wei_pei_yang_demo/studyroom/service/time_factory.dart';
import 'package:wei_pei_yang_demo/studyroom/provider/view_state_refresh_list_model.dart';
import 'package:wei_pei_yang_demo/studyroom/service/data.dart';
import 'package:wei_pei_yang_demo/studyroom/service/hive_manager.dart';
import 'package:wei_pei_yang_demo/studyroom/service/studyroom_repository.dart';
import 'package:wei_pei_yang_demo/studyroom/view_model/schedule_model.dart';

class ClassroomsDataModel extends ViewStateRefreshListModel {
  ClassroomsDataModel({this.scheduleModel});

  SRTimeModel scheduleModel;
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
    for (var c in _area.classrooms.values) {
      var floor = c.name[0];
      var room = Classroom()
        ..name = _area.area_id == '' ? c.name : _area.area_id + c.name
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
    }
  }

  @override
  Future<List> loadData() async {
    var result = await StudyRoomRepository.getWeekClassPlan(dateTime: scheduleModel.dateTime);
    var instance = await HiveManager.instance;
    for (var day in Time.week) {
      var building = await instance.getBuildingPlan(bId: _id, day: day);
      var area = building.areas[_area.area_id];
      if(area == null) continue;
      for(var c in area.classrooms.values) {
        var plan = _classPlan[c.id];
        plan[day] = c.status ?? '';
        _classPlan[c.id] = plan;
      }
    }

    return result;
  }
}
