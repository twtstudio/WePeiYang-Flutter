

import 'package:wei_pei_yang_demo/studyroom/model/building.dart';
import 'package:wei_pei_yang_demo/studyroom/service/time_factory.dart';
import 'package:wei_pei_yang_demo/studyroom/provider/view_state_refresh_list_model.dart';
import 'package:wei_pei_yang_demo/studyroom/service/studyroom_repository.dart';
import 'package:wei_pei_yang_demo/studyroom/view_model/schedule_model.dart';

class BuildingDataModel extends ViewStateRefreshListModel {
  SRTimeModel scheduleModel;
  BuildingDataModel(this.scheduleModel);

  List<Building> _buildings = List();
  List<Building> get buildings => _buildings;

  int get currentDay => scheduleModel.currentDay;
  Schedule get schedule => scheduleModel.schedule;
  DateTime get dateTime => scheduleModel.dateTime;

  /// 之后改成 enmu class
  String _campusId = "1";

  String campus = "卫津路校区";

  set campusId(String campusId){
    _campusId = campusId;
    initData();
  }

  changeCampus() {
    if (_campusId == "1"){
      campus = "北洋园校区";
      campusId = "2";
    }else {
      campus = "卫津路校区";
      campusId = "1";
    }
  }

  @override
  Future<List> loadData() async {
    List<Future> futures = [];
    futures.add(StudyRoomRepository.buildingList());
    if(false) // showFavor
      futures.add(StudyRoomRepository.favouriteList());
    var result = await Future.wait(futures);
    var allBuildings = result[0];
    _buildings.clear();
    allBuildings.forEach((building){
      if(building.campus == _campusId){
        _buildings.add(building);
      }
    });
    print("aaaaa"+allBuildings.toString());
    return result[0];
  }
}
