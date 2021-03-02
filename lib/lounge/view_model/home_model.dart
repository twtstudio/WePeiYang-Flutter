import 'package:wei_pei_yang_demo/lounge/provider/view_state.dart';
import 'package:wei_pei_yang_demo/lounge/provider/view_state_list_model.dart';
import 'package:wei_pei_yang_demo/lounge/service/hive_manager.dart';
import 'package:wei_pei_yang_demo/lounge/view_model/sr_time_model.dart';

class BuildingDataModel extends ViewStateListModel {
  BuildingDataModel(this.scheduleModel) {
    scheduleModel.addListener(() {
      refresh();
    });
  }

  final SRTimeModel scheduleModel;

  DateTime get dateTime => scheduleModel.dateTime;

  Campus get campus => scheduleModel.campus;

  changeCampus() {
    scheduleModel.changeCampus();
    refresh();
  }

  @override
  refresh() async {
    // TODO: implement refresh
    try {
      setBusy();
      List data = await loadData();
      if (scheduleModel.state == ViewState.error) {
        list.clear();
        setError(Exception('refreshDataError'), null);
      } else if (data.isEmpty) {
        list.clear();
        setEmpty();
      } else {
        await onCompleted(data);
        list.clear();
        list.addAll(data);
        setIdle();
      }
    } catch (e, s) {
      list.clear();
      setError(e, s);
    }
  }

  @override
  Future<List> loadData() async {
    await Future.delayed(Duration(seconds: 1));
    return await HiveManager.instance.baseBuildingDataFromDisk
        .where((building) => building.campus == campus.id)
        .toList();
  }
}
