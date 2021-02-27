import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';

class MyColors {
  static final deepBlue = Color.fromRGBO(98, 103, 124, 1.0); //no.1
  static final darkGrey =
      Color.fromRGBO(206, 207, 212, 1.0); //Card label颜色(小图标下的文字,如Bicycle)
  static final darkGrey2 = Color.fromRGBO(116, 119, 138, 1.0); //no.2
  static final brightBlue = Color.fromRGBO(103, 110, 150, 1.0); //no.3
  static final dust = Color.fromRGBO(230, 230, 230, 1.0); //no.4
  static final lessDeepBlue = Color.fromRGBO(69, 91, 117, 1.0); //no.5
  static final myGrey = Color.fromRGBO(245, 245, 245, 1.0);
  static final deepDust = Color.fromRGBO(210, 210, 210, 1.0);
  static final colorList = [
    deepBlue,
    darkGrey2,
    brightBlue,
    dust,
    lessDeepBlue
  ];
}

class FavorColors {
  /// gpa主色调
  static var _gpaColor = PrefsBean<int>("gpaColor", 0x7F8B59);

  static Color get gpaColor => Color(_gpaColor.value);

  /// 课程表主色调，缓存类型是List<String>哦
  static var _scheduleColor =
      PrefsBean<List>("scheduleColor", _scheduleColorDefault);

  static List<Color> get scheduleColor =>
      _scheduleColor.value.map((e) => Color(int.parse(e, radix: 10))).toList();

  /// 调整为默认色调，这里使用fromRGBO可以在ide中显示默认色
  static setDefault() {
    _gpaColor.value = Color.fromRGBO(127, 139, 89, 1).value; // #7F8B59
    _scheduleColor.value = _scheduleColorDefault;
  }

  static final List _scheduleColorDefault = [
    Color.fromRGBO(153, 156, 175, 1).value.toString(), // #999CAF
    Color.fromRGBO(128, 119, 138, 1).value.toString(), // #80778A
    Color.fromRGBO(114, 117, 136, 1).value.toString(), // #727588
  ];
}
