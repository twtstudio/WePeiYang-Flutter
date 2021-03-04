import 'package:wei_pei_yang_demo/lounge/model/classroom.dart';
import 'package:wei_pei_yang_demo/lounge/service/time_factory.dart';
import 'package:wei_pei_yang_demo/lounge/service/hive_manager.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/sr_time_model.dart';
import 'package:wei_pei_yang_demo/lounge/provider/view_state_model.dart';

class ClassPlanModel extends ViewStateListModel {
  ClassPlanModel({this.room, this.scheduleModel}) {
    scheduleModel.addListener(refresh);
  }

  final Classroom room;
  final SRTimeModel scheduleModel;

  DateTime get dateTime => scheduleModel.dateTime;

  List<ClassTime> get classTime => scheduleModel.classTime;

  final Map<String, List<String>> _plans = {};

  Map<String, List<String>> get plan => _plans;

  @override
  refresh() async {
    setBusy();
    if (scheduleModel.state == ViewState.error) {
      setError(Exception('refresh data error when change date'), null);
    } else if (scheduleModel.state == ViewState.idle) {
      super.refresh();
    }
  }

  @override
  Future<List> loadData() async {

    // await Future.delayed(Duration(seconds: 1));

    _plans.clear();
    var plan = await HiveManager.instance
        .getRoomPlans(r: room, dateTime: scheduleModel.dateTime);
    _plans.addAll(plan);
    return _plans.values.toList();
  }
}
