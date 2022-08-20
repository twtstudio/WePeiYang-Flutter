// @dart = 2.12
import 'package:flutter/material.dart' show Color, Colors;
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';

class MyColors {
  static final deepBlue = Color.fromRGBO(98, 103, 124, 1.0); //no.1
  static final brightBlue = Color.fromRGBO(103, 110, 150, 1.0); //no.3
}

class FavorColors {
  FavorColors._();

  /// gpa主色调，缓存类型是List<String>哦
  static final _gpaColor = PrefsBean<List>("gpaColor", _blueGPA);

  static List<Color> get gpaColor =>
      _gpaColor.value.map((e) => Color(int.parse(e, radix: 10))).toList();

  /// 单独用个变量存种类
  static final gpaType = PrefsBean<String>("gpaColorType", 'blue');

  /// 课程表主色调，缓存类型是List<String>哦
  static final _scheduleColor = PrefsBean<List>("scheduleColor", _blueSchedule);

  static List<Color> get scheduleColor =>
      _scheduleColor.value.map((e) => Color(int.parse(e, radix: 10))).toList();

  static final scheduleType = PrefsBean<String>("scheduleColorType", 'blue');

  /// 这个是GPA默认颜色哦
  static setGreenRelatedGPA() {
    _gpaColor.value = _greenGPA;
    gpaType.value = 'green';
  }

  static setBlueRelatedGPA() {
    _gpaColor.value = _blueGPA;
    gpaType.value = 'blue';
  }

  static setPinkRelatedGPA() {
    _gpaColor.value = _pinkGPA;
    gpaType.value = 'pink';
  }

  static setLightRelatedGPA() {
    _gpaColor.value = _lightGPA;
    gpaType.value = 'light';
  }

  static setBegoniaGPA() {
    _gpaColor.value = _begoniaGPA;
    gpaType.value = 'begonia';
  }

  static final List<String> _greenGPA = [
    Color.fromRGBO(127, 139, 89, 1).value.toString(),
    Color.fromRGBO(255, 255, 255, 1).value.toString(),
    Color.fromRGBO(179, 183, 155, 1).value.toString(),
    Color.fromRGBO(136, 148, 102, 1).value.toString(),
  ];

  static final List<String> _blueGPA = [
    Color(0xFF2C7EDF).value.toString(),
    Colors.white.value.toString(),
    Color(0xFFA6CFFF).value.toString(),
    Colors.white.value.toString(),
  ];

  static final List<String> _pinkGPA = [
    Color.fromRGBO(173, 141, 146, 1).value.toString(),
    Color.fromRGBO(247, 247, 248, 1).value.toString(),
    Color.fromRGBO(233, 220, 223, 1).value.toString(),
    Color.fromRGBO(180, 150, 155, 1).value.toString(),
  ];

  static final List<String> _lightGPA = [
    Color.fromRGBO(245, 237, 237, 1.0).value.toString(),
    Color.fromRGBO(253, 253, 254, 1.0).value.toString(),
    Color.fromRGBO(184, 162, 167, 1).value.toString(),
    Color.fromRGBO(227, 222, 222, 1).value.toString(),
  ];

  static final List<String> _begoniaGPA = [
    Color.fromRGBO(228, 181, 189, 1.0).value.toString(),
    Color.fromRGBO(253, 253, 254, 1.0).value.toString(),
    Color.fromRGBO(221, 172, 179, 1.0).value.toString(),
    Color.fromRGBO(217, 162, 169, 1.0).value.toString(),
  ];

  /// 这个是课程表默认颜色哦
  static setBlueRelatedSchedule() {
    _scheduleColor.value = _blueSchedule;
    scheduleType.value = 'blue';
  }

  static setGreenRelatedSchedule() {
    _scheduleColor.value = _greenSchedule;
    scheduleType.value = 'green';
  }

  static setBrownRelatedSchedule() {
    _scheduleColor.value = _brownSchedule;
    scheduleType.value = 'brown';
  }

  static setBegoniaSchedule() {
    _scheduleColor.value = _begoniaSchedule;
    scheduleType.value = 'begonia';
  }

  static setAprilFoolSchedule() {
    scheduleType.value = 'april';
  }

  static Color get scheduleTitleColor {
    if (CommonPreferences.isSkinUsed.value) {
      return Color(CommonPreferences.skinColorB.value);
    }
    var type = scheduleType.value;
    if (type == 'green')
      return Color.fromRGBO(115, 124, 105, 1);
    else if (type == 'brown')
      return Color.fromRGBO(128, 95, 78, 1);
    else if (type == 'blue')
      return Color.fromRGBO(98, 103, 123, 1);
    else if (type == 'april')
      return Color.fromRGBO(98, 103, 123, 1);
    else
      return Color.fromRGBO(115, 124, 105, 1);
  }

  /// 这套配色暴露出来给主页使用
  static final List<Color> homeSchedule =
      _begoniaSchedule.map((e) => Color(int.parse(e, radix: 10))).toList();
  static final List<Color> defaultHomeSchedule =
      _blueSchedule.map((e) => Color(int.parse(e, radix: 10))).toList();
  static final List<String> _blueSchedule = [
    Color.fromRGBO(114, 117, 136, 1).value.toString(), // #727588
    Color.fromRGBO(143, 146, 165, 1).value.toString(), // #8F92A5
    Color.fromRGBO(122, 119, 138, 1).value.toString(), // #7A778A
    Color.fromRGBO(142, 122, 150, 1).value.toString(), // #8E7A96
    Color.fromRGBO(130, 134, 161, 1).value.toString(), // #8286A1
  ];

  static final List<String> _greenSchedule = [
    Color.fromRGBO(127, 148, 105, 1).value.toString(),
    Color.fromRGBO(188, 200, 178, 1).value.toString(),
    Color.fromRGBO(100, 109, 90, 1).value.toString(),
    Color.fromRGBO(173, 180, 147, 1).value.toString(),
    Color.fromRGBO(83, 89, 78, 1).value.toString(),
    Color.fromRGBO(165, 180, 149, 1).value.toString(),
  ];

  static final List<String> _brownSchedule = [
    Color.fromRGBO(159, 136, 118, 1).value.toString(),
    Color.fromRGBO(196, 148, 125, 1).value.toString(),
    Color.fromRGBO(212, 188, 162, 1).value.toString(),
    Color.fromRGBO(128, 95, 78, 1).value.toString(),
    Color.fromRGBO(201, 169, 148, 1).value.toString(),
    Color.fromRGBO(102, 88, 82, 1).value.toString(),
  ];
  static final List<String> _begoniaSchedule = [
    Color.fromRGBO(245, 224, 238, 1.0).value.toString(),
    Color.fromRGBO(221, 182, 190, 1.0).value.toString(),
    Color.fromRGBO(236, 206, 217, 1.0).value.toString(),
    Color.fromRGBO(236, 206, 217, 1.0).value.toString(),
    Color.fromRGBO(221, 182, 190, 1.0).value.toString(),
  ];
}
