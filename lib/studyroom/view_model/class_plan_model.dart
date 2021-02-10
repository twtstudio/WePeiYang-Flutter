

import 'package:wei_pei_yang_demo/studyroom/model/time.dart';
import 'package:wei_pei_yang_demo/studyroom/provider/view_state_refresh_list_model.dart';
import 'package:wei_pei_yang_demo/studyroom/service/hive_manager.dart';
import 'package:wei_pei_yang_demo/studyroom/view_model/schedule_model.dart';

class ClassPlanModel extends ViewStateRefreshListModel {
  ClassPlanModel({this.scheduleModel});

  ScheduleModel scheduleModel;

  int get currentDay => scheduleModel.currentDay;

  Schedule get schedule => scheduleModel.schedule;
  String _aId = '';
  String _bId = '';
  String _cId = '';

  setRoomPath(String aId, String bId, String cId) {
    _aId = aId;
    _bId = bId;
    _cId = cId;
  }

  Map<String, List<String>> _plans = {};

  Map<String, List<String>> get plan => _plans;

  List<String> splitPlan(String plan) {
    var list = plan.split('');
    var p = list.first;
    var index = 0;
    var n = '';
    List<String> sPlan = [];
    do {
      n = n + list[index];
      index++;
      if (p != list[index]) {
        sPlan.add(n);
        n = '';
        p = list[index];
      } else if (index == plan.length - 1) {
        if (p != list[index]) {
          sPlan.add(n);
          sPlan.add(list[index]);
        } else {
          n = n + list[index];
          sPlan.add(n);
        }
        break;
      }
    } while (index <= plan.length - 1);
    List<String> result = [];
    for (var p in sPlan) {
      if (p.contains('0')) {
        result.add(p);
        continue;
      }
      if (p.length > 3) {
        var s = '';
        var index = 0;
        var l = p.length;
        do {
          if (index == l - 3) {
            s = p.substring(index, l);
            result.add(s);
          } else {
            s = p.substring(index, index + 2);
            result.add(s);
            index = index + 2;
            if (index == l - 2) {
              s = p.substring(index, index + 2);
              result.add(s);
              index = index + 2;
            }
          }
        } while (index <= l - 3);
      } else {
        result.add(p);
      }
    }
    return result;
  }

  @override
  Future<List> loadData() async {
    var instance = await HiveManager.instance;
    var box = instance.buildingBoxes[_bId];
    for (var day in Time.week) {
      _plans[day] = ['11', '11', '11', '11', '11', '11'];
      var building = await box.get(day);
      var fArea = building.areas.first;
      if (fArea.area_id == null) {
        for (var room in fArea.classrooms) {
          if (room.id == _cId) {
            _plans[day] = splitPlan(room.status);
          }
        }
      } else {
        for (var area in building.areas) {
          if (area.area_id == _aId) {
            for (var room in area.classrooms) {
              if (room.id == _cId) {
                _plans[day] = splitPlan(room.status);
              }
            }
          }
        }
      }
    }
    print(_plans.values.toList());
    print(_plans.keys.toList());

    return _plans.values.toList();
  }
}
