import 'package:wei_pei_yang_demo/lounge/model/classroom.dart';
import 'package:wei_pei_yang_demo/lounge/provider/view_state_list_model.dart';
import 'package:wei_pei_yang_demo/lounge/service/time_factory.dart';
import 'package:wei_pei_yang_demo/lounge/service/hive_manager.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/sr_time_model.dart';

class ClassPlanModel extends ViewStateListModel {
  ClassPlanModel({this.room,this.scheduleModel}){
    scheduleModel.addListener(() {
      refresh();
    });
  }

  final Classroom room;
  final SRTimeModel scheduleModel;

  DateTime get dateTime => scheduleModel.dateTime;
  List<Schedule> get schedule => scheduleModel.schedule;

  Map<String, List<String>> _plans = {};
  Map<String, List<String>> get plan => _plans;

  @override
  Future<List> loadData() async {
    _plans = await HiveManager.instance.getClassPlans(r: room,dateTime: scheduleModel.dateTime);
    print(_plans.values.toList());
    print(_plans.keys.toList());

    return _plans.values.toList();
  }
}
