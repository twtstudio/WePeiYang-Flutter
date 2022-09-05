// @dart = 2.12
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/lounge/util/time_util.dart';

class LoungeConfig extends ChangeNotifier {
  List<ClassTime> _timeRange = [];

  DateTime _dateTime = DateTime.now();

  DateTime get dateTime => _dateTime;

  List<ClassTime> get timeRange => _timeRange;

  setTime({DateTime? date, List<ClassTime>? range}) {
    final timeRange = range ?? _timeRange;
    final dateTime = date ?? _dateTime;

    _timeRange = timeRange;
    _dateTime = dateTime;

    notifyListeners();
  }

  Campus _campus = Campus.wjl.init;

  Campus get campus => _campus;

  CrossFadeState get state => _campus.state;

  changeCampus() {
    _campus = _campus.change;
    notifyListeners();
  }
}

enum Campus { wjl, byy }

extension CampusExtension on Campus {
  List<Campus> get campuses => [Campus.wjl, Campus.byy];

  Campus get change {
    var next = (index + 1) % 2;
    CommonPreferences.lastChoseCampus.value = next;
    return campuses[next];
  }

  Campus get init => Campus.values[CommonPreferences.lastChoseCampus.value];

  String get id => ['1', '2'][index];

  String get name => ['卫津路', '北洋园'][index];

  CrossFadeState get state => CrossFadeState.values[index];

  bool get isWjl => this == Campus.wjl;

  bool get isByy => this == Campus.byy;
}