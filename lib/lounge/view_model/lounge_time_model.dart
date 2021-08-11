import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/lounge/provider/view_state_model.dart';
import 'package:we_pei_yang_flutter/lounge/service/hive_manager.dart';
import 'package:we_pei_yang_flutter/lounge/service/repository.dart';
import 'package:we_pei_yang_flutter/lounge/service/time_factory.dart';

class LoungeTimeModel extends ChangeNotifier {
  List<ClassTime> _classTime;

  List<ClassTime> get classTime => _classTime;

  DateTime _dateTime;

  DateTime get dateTime => _dateTime;

  Campus _campus = Campus.WJL.init;

  Campus get campus => _campus;

  changeCampus() => _campus = _campus.change;

  ViewState _state;

  ViewState get state => _state;

  String reloadFavouriteList;

  Future<void> setTime({
    DateTime date,
    List<ClassTime> schedule,
    bool init = false,
  }) async {
    List<ClassTime> preCs;
    DateTime preD;
    // debugPrint(
    //     '++++++++++++++++ lounge time model change time +++++++++++++++++++');
    _state = ViewState.busy;
    if (_classTime == null && _dateTime == null) {
      var current = Time.classOfDay(DateTime.now());
      // var current = Time.classOfDay(DateTime(2021, 4, 18, 22, 25));
      _classTime = [current.classTime];
      _dateTime = checkDateTimeAvailable(current.date);
    } else {
      preCs = [..._classTime];
      preD = DateTime.parse(_dateTime.toString());
      _classTime = schedule ?? _classTime;
      _dateTime = checkDateTimeAvailable(date) ?? _dateTime;
    }
    if (!init) {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        // print(
        //     "===============    notifyListeners  ${_state.toString()} ===============");
        notifyListeners();
        try {
          await LoungeRepository.setLoungeData(model: this);
          _state = ViewState.idle;
          notifyListeners();
        } catch (_) {
          ToastProvider.error("加载数据失败");
          // print("preD : ${preD.toString()}");
          if (HiveManager.instance.shouldUpdateLocalData) {
            var localLastUpdateTime =
                HiveManager.instance.localDateLastUpdateTime;
            if (localLastUpdateTime == null) {
              _state = ViewState.error;
              _dateTime = preD;
            } else {
              _dateTime = checkDateTimeAvailable(localLastUpdateTime);
              _state = ViewState.idle;
            }
          } else {
            _dateTime = preD;
            _state = ViewState.idle;
          }
          // _classTime = preCs;
          notifyListeners();
        }
      } else if ((_dateTime.isThisWeek &&
              !HiveManager.instance.shouldUpdateLocalData) ||
          !HiveManager.instance
              .shouldUpdateTemporaryData(dateTime: _dateTime)) {
        // ToastProvider.success("虽然没有网络连接，但是我有本地数据");
        _state = ViewState.idle;
        notifyListeners();
      } else {
        // print("preD ${preD.toString()}");
        if (!_dateTime.isTheSameDay(preD)) {
          ToastProvider.error("没有网络连接");
          _classTime = preCs;
        }
        _dateTime = preD;
        _state = ViewState.idle;
        notifyListeners();
      }

      return;
    }
    _state = ViewState.idle;
  }
}

enum Campus { WJL, BYY }

extension CampusExtension on Campus {
  List<Campus> get campuses => [Campus.WJL, Campus.BYY];

  Campus get change {
    var next = (this.index + 1) % 2;
    CommonPreferences().lastChoseCampus.value = next;
    return campuses[next];
  }

  Campus get init => Campus.values[CommonPreferences().lastChoseCampus.value];

  String get id => ['1', '2'][this.index];

  String get name => [S.current.WJL, S.current.BYY][this.index];
}

DateTime checkDateTimeAvailable(DateTime dateTime) {
   if(dateTime != null){
     if (dateTime.isBefore(Time.semesterStart())) {
       return Time.semesterStart();
     }
   }
   return dateTime;
}
