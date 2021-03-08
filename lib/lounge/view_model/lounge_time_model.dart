import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/generated/l10n.dart';
import 'package:wei_pei_yang_demo/lounge/provider/view_state_model.dart';
import 'package:wei_pei_yang_demo/lounge/service/repository.dart';
import 'package:wei_pei_yang_demo/lounge/service/time_factory.dart';

class LoungeTimeModel extends ChangeNotifier {
  List<ClassTime> _classTime;

  List<ClassTime> get classTime => _classTime;

  DateTime _dateTime;

  DateTime get dateTime => _dateTime;

  Campus _campus = Campus.WJL;

  Campus get campus => _campus;

  changeCampus() => _campus = _campus.change;

  ViewState _state;

  ViewState get state => _state;

  String reloadFavouriteList;

  setTime({
    DateTime date,
    List<ClassTime> schedule,
    bool init = false,
  }) async {
    debugPrint('++++++++++++++++ lounge time model change time +++++++++++++++++++');
    _state = ViewState.busy;
    if (_classTime == null && _dateTime == null) {
      _classTime = [Time.classOfDay(DateTime.now())];
      _dateTime = DateTime.now();
    } else {
      _classTime = schedule ?? _classTime;
      _dateTime = date ?? _dateTime;
    }
    notifyListeners();
    if(!init){
      try {
        await LoungeRepository.setLoungeData(model: this);
        _state = ViewState.idle;
      } catch (_) {
        _state = ViewState.error;
      }
      notifyListeners();
      return;
    }
    _state = ViewState.idle;
  }
}

enum Campus { WJL, BYY }

extension CampusExtension on Campus {
  Campus get change => [Campus.BYY, Campus.WJL][this.index];

  String get id => ['1', '2'][this.index];

  String get name => [S.current.WJL, S.current.BYY][this.index];
}
