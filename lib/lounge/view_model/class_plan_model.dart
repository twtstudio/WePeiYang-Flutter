import 'package:flutter/foundation.dart';
import 'package:wei_pei_yang_demo/lounge/model/classroom.dart';
import 'package:wei_pei_yang_demo/lounge/service/time_factory.dart';
import 'package:wei_pei_yang_demo/lounge/service/hive_manager.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/lounge_time_model.dart';
import 'package:wei_pei_yang_demo/lounge/provider/view_state_model.dart';

class ClassPlanModel extends ViewStateListModel {
  ClassPlanModel({this.room, this.timeModel}) {
    timeModel.addListener(refresh);
  }

  final Classroom room;
  final LoungeTimeModel timeModel;

  DateTime get dateTime => timeModel.dateTime;

  List<ClassTime> get classTime => timeModel.classTime;

  final Map<String, List<String>> _plans = {};

  Map<String, List<String>> get plan => _plans;

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

    _plans.clear();
    var plan = await HiveManager.instance
        .getRoomPlans(r: room, dateTime: timeModel.dateTime);
    _plans.addAll(plan);
    return _plans.values.toList();
  }
}
