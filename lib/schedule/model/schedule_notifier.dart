import 'package:flutter/material.dart';
import 'package:wei_pei_yang_demo/commons/preferences/common_prefs.dart';
import 'package:wei_pei_yang_demo/commons/util/toast_provider.dart';
import 'package:wei_pei_yang_demo/schedule/model/school/school_model.dart';
import 'package:wei_pei_yang_demo/schedule/network/schedule_spider.dart';

class ScheduleNotifier with ChangeNotifier {
  List<Course> _courses = [];

  /// 外部更新课表总数据时调用（如网络请求）
  set coursesWithNotify(List<Course> newList) {
    _courses = newList;
    notifyListeners();
  }

  List<Course> get coursesWithNotify => _courses;

  /// 每学期的开始时间
  int _termStart = 1598803200;

  int get termStart => _termStart;

  /// 当前显示的星期
  int _selectedWeek = 1;

  set selectedWeekWithNotify(int newSelected) {
    if (_selectedWeek == newSelected) return;
    _selectedWeek = newSelected;
    notifyListeners();
  }

  int get selectedWeekWithNotify => _selectedWeek;

  void quietResetWeek() => _selectedWeek = _currentWeek;

  int _currentWeek = 1;

  int get currentWeekWithNotify => _currentWeek;

  set currentWeekWithNotify(int newWeek) {
    if (_currentWeek == newWeek) return;
    _currentWeek = newWeek;
    _selectedWeek = newWeek;
    notifyListeners();
  }

  /// 一学期一共有多少周……很没存在感的东西
  int _weekCount = 25;

  int get weekCount => _weekCount;

  // TODO 这个先不动了吧
  set weekCount(int newCount) {
    // if (_weekCount == newCount) return;
    // _weekCount = newCount;
  }

  /// 通过爬虫刷新数据
  RefreshCallback refreshSchedule({bool hint = true}) {
    return () async {
      if(hint) ToastProvider.running("刷新数据中……");
      getSchedule(
          onSuccess: (schedule) {
            if(hint) ToastProvider.success("刷新课程表数据成功");
            _termStart = schedule.termStart;
            _courses = schedule.courses;
            notifyListeners(); // 通知各widget进行更新
          },
          onFailure: (e) => ToastProvider.error(e.error.toString()));
    };
  }

  /// 夜猫子模式
  bool _nightMode = false;

  set nightMode(bool value) {
    _nightMode = value;
    notifyListeners();
  }

  bool get nightMode {
    /// notifier和缓存不同的唯一情况，就是初次加载时，notifier为false，缓存为true的情况。这时候听缓存的
    _nightMode = CommonPreferences().nightMode.value;
    return _nightMode;
  }

  /// 办公网解绑时清除数据
  void clear() {
    _courses = [];
    _selectedWeek = 1;
    notifyListeners();
  }
}
