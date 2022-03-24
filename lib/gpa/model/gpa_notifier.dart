import 'dart:convert' show json;
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/gpa/model/gpa_model.dart';
import 'package:we_pei_yang_flutter/gpa/network/gpa_spider.dart';

class GPANotifier with ChangeNotifier {
  /// 每学期的gpa数据
  List<GPAStat> _gpaStats = [];

  /// 外部更新gpa总数据时调用
  set gpaStatsWithNotify(List<GPAStat> newList) {
    _gpaStats = newList;
    _sort();
    notifyListeners();
  }

  /// 所有学期的gpa总数居
  Total total = Total(0, 0, 0);

  /// 当前显示的学年
  int _index = 0;

  int get indexWithNotify => _index;

  set indexWithNotify(int newIndex) {
    if (newIndex == _index) return;
    _index = newIndex;
    notifyListeners();
  }

  /// 曲线上显示的种类, 0->weighted  1->gpa  2->credits
  int _type = 1;

  set typeWithNotify(int newType) {
    if (newType == _type) return;
    _type = newType;
    notifyListeners();
  }

  /// 通过[_type]获取种类名称

  String typeName() {
    if (_type == 0) return "加权";
    if (_type == 1) return "绩点";
    if (_type == 2) return "学分";
    return "Error";
  }

  /// 获取当前学年的weighted、gpa、credits
  /// 也可用来判断当前数据是否为空（如gpa_page.dart: [GPAStatsWidget]）
  List<double> get currentDataWithNotify {
    if (_gpaStats.length == 0) return null;
    var li = _gpaStats[_index];
    return [li.weighted, li.gpa, li.credits];
  }

  /// 获取曲线上的数据
  List<double> get curveDataWithNotify {
    var doubles = <double>[];
    if (_type == 0) for (var i in _gpaStats) doubles.add(i.weighted);
    if (_type == 1) for (var i in _gpaStats) doubles.add(i.gpa);
    if (_type == 2) for (var i in _gpaStats) doubles.add(i.credits);
    return doubles;
  }

  /// 获取当前学年的course detail
  List<GPACourse> get coursesWithNotify {
    if (_gpaStats.length == 0) return [];
    return _gpaStats[_index].courses;
  }

  /// list的排列方式， 0->name 1->score 2->credit
  int _sortType = 0;

  String get sortType {
    switch (_sortType) {
      case 0:
        return "name";
      case 1:
        return "score";
      case 2:
        return "credits";
    }
    return "name";
  }

  /// 分别按 name、score、credit 排序
  void _sort() {
    switch (_sortType) {
      case 0:
        _gpaStats.forEach((element) {
          element.courses.sort((b, a) => a.name.compareTo(b.name));
        });
        break;
      case 1:
        _gpaStats.forEach((element) {
          element.courses.sort((b, a) => a.score.compareTo(b.score));
        });
        break;
      case 2:
        _gpaStats.forEach((element) {
          element.courses.sort((b, a) => a.credit.compareTo(b.credit));
        });
        break;
    }
    notifyListeners();
  }

  /// 更换排列方式
  void reSort() {
    _sortType = (_sortType + 1) % 3;
    _sort();
  }

  /// notifier中也写一个hideGPA，就可以在从设置页面pop至主页时，令主页的GPAWidget进行rebuild
  set hideGPA(bool value) {
    CommonPreferences().hideGPA.value = value;
    notifyListeners();
  }

  bool get hideGPA => CommonPreferences().hideGPA.value;

  GestureTapCallback refreshGPA({bool hint = false, OnFailure onFailure}) {
    return () {
      if (hint) ToastProvider.running("刷新数据中……");
      getGPABean(onResult: ( gpaBean) {
        if (hint) ToastProvider.success("刷新gpa数据成功");
        _gpaStats = gpaBean.stats;
        total = gpaBean.total;
        notifyListeners();
        CommonPreferences().gpaData.value = json.encode(gpaBean);
      }, onFailure: (e) {
        if (onFailure != null) onFailure(e);
      });
    };
  }

  /// 从缓存中读课表的数据，进入主页之前调用
  void readPref() {
    var pref = CommonPreferences();
    if (pref.gpaData.value == '') return;
    GPABean gpaBean = GPABean.fromJson(json.decode(pref.gpaData.value));
    _gpaStats = gpaBean.stats;
    total = gpaBean.total;
    notifyListeners();
  }

  /// 办公网解绑时清除数据
  void clear() {
    _gpaStats = [];
    total = Total(0, 0, 0);
    _index = 0;
    _type = 0;
    _sortType = 0;
    notifyListeners();
  }
}
