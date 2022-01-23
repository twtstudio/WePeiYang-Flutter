import 'dart:convert' show json;
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/commons/network/dio_abstract.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/school_model.dart';
import 'package:we_pei_yang_flutter/schedule/network/schedule_spider.dart';

class ScheduleNotifier with ChangeNotifier {
  List<ScheduleCourse> _courses = [];

  /// 外部更新课表总数据时调用（如网络请求）
  set coursesWithNotify(List<ScheduleCourse> newList) {
    _courses = newList;
    notifyListeners();
  }

  List<ScheduleCourse> get coursesWithNotify => _courses;

  int get termStart => CommonPreferences().termStart.value;

  /// 学期名
  String get termName => CommonPreferences().termName.value;

  /// 当前显示的星期
  int _selectedWeek = 1;

  set selectedWeekWithNotify(int newSelected) {
    if (_selectedWeek == newSelected) return;
    _selectedWeek = newSelected;
    notifyListeners();
  }

  int get selectedWeekWithNotify => _selectedWeek;

  void quietResetWeek() => _selectedWeek = currentWeek;

  static const dayOfSeconds = 86400;

  static const weekOfSeconds = 604800;

  /// 手动计算当前周,不从办公网爬了
  int get currentWeek {
    if (isBeforeTermStart) return 1; // 防止week为负数
    var week = ((DateTime.now().millisecondsSinceEpoch / 1000 - termStart) /
            weekOfSeconds)
        .ceil();
    if (week > weekCount) week = weekCount; // 如果后台一直不更新termStart, 这里要防止越界
    return week;
  }

  bool get isBeforeTermStart =>
      DateTime.now().millisecondsSinceEpoch / 1000 < termStart;

  /// 这个是专门给首页的课程用的，因为有夜猫子模式
  bool get isOneDayBeforeTermStart =>
      (DateTime.now().millisecondsSinceEpoch / 1000 + dayOfSeconds) < termStart;

  // TODO 一学期一共有多少周，暂时写死，之后手动获取
  int weekCount = 27;

  /// 夜猫子模式，这个变量的主要作用是通知widget更新
  set nightMode(bool value) {
    CommonPreferences().nightMode.value = value;
    notifyListeners();
  }

  bool get nightMode => CommonPreferences().nightMode.value;

  /// 通过爬虫刷新数据
  RefreshCallback refreshSchedule({bool hint = false, OnFailure onFailure}) {
    return () async {
      if (hint) ToastProvider.running("刷新数据中……");
      getScheduleCourses(onResult: (courses) {
        if (hint) ToastProvider.success("刷新课程表数据成功");
        _courses = courses;
        notifyListeners(); // 通知各widget进行更新
        CommonPreferences().scheduleData.value =
            json.encode(ScheduleBean(termStart, termName, courses)); // 刷新本地缓存
        messageChannel?.invokeMethod("refreshScheduleWidget"); // 刷新课程表widget
      }, onFailure: (e) {
        if (onFailure != null) onFailure(e);
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
    notifyListeners();
  }

  /// 办公网解绑时清除数据
  void clear() {
    _courses = [];
    _selectedWeek = 1;
    notifyListeners();
  }
}
