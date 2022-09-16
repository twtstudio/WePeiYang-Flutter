//@dart=2.12
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';

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

  String get campusName => ['卫津路', '北洋园'][index];

  CrossFadeState get state => CrossFadeState.values[index];

  bool get isWjl => this == Campus.wjl;

  bool get isByy => this == Campus.byy;
}
