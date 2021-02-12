

import 'package:wei_pei_yang_demo/studyroom/model/time.dart';
import 'package:wei_pei_yang_demo/studyroom/provider/view_state_refresh_list_model.dart';
import 'package:wei_pei_yang_demo/studyroom/service/hive_manager.dart';
import 'package:wei_pei_yang_demo/studyroom/view_model/schedule_model.dart';

class ClassPlanModel extends ViewStateRefreshListModel {
  ClassPlanModel({this.aId, this.bId, this.cId,this.scheduleModel});

  SRTimeModel scheduleModel;

  int get currentDay => scheduleModel.currentDay;

  Schedule get schedule => scheduleModel.schedule;
  final String aId;
  final String bId;
  final String cId;

  Map<String, List<String>> _plans = {};

  Map<String, List<String>> get plan => _plans;

  @override
  Future<List> loadData() async {
    var instance = await HiveManager.instance;
    _plans = await instance.getClassPlans(bId: bId, aId: aId, cId: cId);
    print(_plans.values.toList());
    print(_plans.keys.toList());

    return _plans.values.toList();
  }
}
