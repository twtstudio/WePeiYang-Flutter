import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:wei_pei_yang_demo/schedule/model/school/school_model.dart';
import 'package:wei_pei_yang_demo/schedule/network/schedule_spider.dart';

class ScheduleNotifier with ChangeNotifier {
  void notify() => notifyListeners.call();

  List<ScheduleCourse> _courses = [];

  /// 外部更新课表总数据时调用（如网络请求）
  set coursesWithNotify(List<ScheduleCourse> newList) {
    _courses = newList;
    notifyListeners();
  }

  List<ScheduleCourse> get coursesWithNotify => _courses;

  /// 每学期的开始时间
  // TODO 这个得上接口
  int _termStart = 1614528000;

  int get termStart => _termStart;

  /// 当前显示的星期
  int _selectedWeek = 1;

  set selectedWeekWithNotify(int newSelected) {
    if (_selectedWeek == newSelected) return;
    _selectedWeek = newSelected;
    notifyListeners();
  }

  int get selectedWeekWithNotify => _selectedWeek;

  void quietResetWeek() => _selectedWeek = currentWeek;

  /// 手动计算当前周,不从办公网爬了
  int get currentWeek =>
      ((DateTime.now().millisecondsSinceEpoch / 1000 - termStart) / 604800)
          .ceil();

  /// 一学期一共有多少周……很没存在感的东西
  int _weekCount = 25;

  int get weekCount => _weekCount;

  // TODO 这个先不爬了吧
  set weekCount(int newCount) {
    if (_weekCount == newCount) return;
    _weekCount = newCount;
  }

  /// 夜猫子模式
  bool _nightMode = true;

  set nightMode(bool value) {
    _nightMode = value;
    notifyListeners();
  }

  bool get nightMode {
    /// notifier和缓存不同的唯一情况，就是初次加载时，notifier为false，缓存为true的情况。这时候听缓存的
    _nightMode = CommonPreferences().nightMode.value;
    return _nightMode;
  }

  /// 通过爬虫刷新数据
  RefreshCallback refreshSchedule(
      {bool hint = true, void Function() onFailure}) {
    return () async {
      if (hint) ToastProvider.running("刷新数据中……");
      getScheduleCourses(onResult: (courses) {
        if (hint) ToastProvider.success("刷新课程表数据成功");
        _courses = courses;
        notifyListeners(); // 通知各widget进行更新
        CommonPreferences().scheduleData.value =
            json.encode(ScheduleBean(_termStart, "20212", courses));
      }, onFailure: (e) {
        if (hint && onFailure == null) ToastProvider.error(e.error);
        if (onFailure != null) onFailure();
      });
    };
  }

  /// 从缓存中读课表的数据，进入主页之前调用
  void readPref() {
    var pref = CommonPreferences();
    if (pref.scheduleData.value == '') return;
    ScheduleBean schedule =
        ScheduleBean.fromJson(json.decode(pref.scheduleData.value));
    _courses = schedule.courses;
    _termStart = schedule.termStart;
    notifyListeners();
  }

  /// 办公网解绑时清除数据
  void clear() {
    _courses = [];
    _selectedWeek = 1;
    notifyListeners();
  }
}
