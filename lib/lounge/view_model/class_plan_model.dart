import 'package:wei_pei_yang_demo/lounge/model/classroom.dart';
import 'package:wei_pei_yang_demo/lounge/provider/view_state_list_model.dart';
import 'package:wei_pei_yang_demo/lounge/service/time_factory.dart';
import 'package:wei_pei_yang_demo/lounge/service/hive_manager.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/sr_time_model.dart';

class ClassPlanModel extends ViewStateListModel {
  ClassPlanModel({this.room, this.scheduleModel}) {
    scheduleModel.addListener(() {
      setBusy();
      refresh();
    });
  }

  final Classroom room;
  final SRTimeModel scheduleModel;

  DateTime get dateTime => scheduleModel.dateTime;

  List<ClassTime> get classTime => scheduleModel.classTime;

  final Map<String, List<String>> _plans = {};

  Map<String, List<String>> get plan => _plans;

  @override
  Future<List> loadData() async {
    _plans.clear();
    var plan = await HiveManager.instance
        .getRoomPlans(r: room, dateTime: scheduleModel.dateTime);
    _plans.addAll(plan);
    return _plans.values.toList();
  }
}
