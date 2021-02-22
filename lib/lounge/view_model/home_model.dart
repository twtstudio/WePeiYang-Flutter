import 'package:wei_pei_yang_demo/lounge/model/building.dart';
import 'package:wei_pei_yang_demo/lounge/provider/view_state_list_model.dart';
import 'package:wei_pei_yang_demo/lounge/service/hive_manager.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/sr_time_model.dart';

class BuildingDataModel extends ViewStateListModel {
  BuildingDataModel(this.scheduleModel);

  final SRTimeModel scheduleModel;

  DateTime get dateTime => scheduleModel.dateTime;

  Campus campus = Campus.WJL;

  changeCampus() {
    campus = campus.change;
    initData();
  }

  @override
  Future<List> loadData() async {
    return await HiveManager.instance.baseBuildingDataFromDisk
        .where((building) => building.campus == campus.id)
        .toList();
  }
}

enum Campus { WJL, BYY }

extension CampusExtension on Campus {
  Campus get change => [Campus.BYY, Campus.WJL][this.index];

  String get id => ['1', '2'][this.index];

  String get name => ['卫津路', '北洋园'][this.index];
}
