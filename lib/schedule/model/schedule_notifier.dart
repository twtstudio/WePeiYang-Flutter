import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/school/school_model.dart';
import 'package:we_pei_yang_flutter/schedule/network/schedule_spider.dart';

class ScheduleNotifier with ChangeNotifier {
  void notify() => notifyListeners.call();

  List<ScheduleCourse> _courses = [];

  /// 外部更新课表总数据时调用（如网络请求）
  set coursesWithNotify(List<ScheduleCourse> newList) {
    _courses = newList;
    notifyListeners();
  }

  List<ScheduleCourse> get coursesWithNotify => _courses;

  /// 每学期的开始时间，由于后端接口问题，要减去8小时偏移量
  int get termStart => CommonPreferences().termStart.value - 3600 * 8;

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
    var week = ((DateTime.now().millisecondsSinceEpoch / 1000 - termStart) / weekOfSeconds)
        .ceil();
    if(week > _weekCount) week = _weekCount; // 如果后台一直不更新termStart, 这里要防止越界
    return week;
  }

  bool get isBeforeTermStart => DateTime.now().millisecondsSinceEpoch / 1000 < termStart;

  /// 这个是专门给首页的课程用的，因为有夜猫子模式
  bool get isOneDayBeforeTermStart => (DateTime.now().millisecondsSinceEpoch / 1000 + dayOfSeconds) < termStart;

  /// 一学期一共有多少周……这个就先写死了
  // TODO 怎么一学期有27周，看来还是得手动获取
  int _weekCount = 27;

  int get weekCount => _weekCount;

  /// 夜猫子模式，这个变量的主要作用是通知widget更新
  bool _nightMode = true;

  set nightMode(bool value) {
    _nightMode = value;
    notifyListeners();
  }

  bool get nightMode {
    _nightMode = CommonPreferences().nightMode.value; /// 优先听缓存的
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
            json.encode(ScheduleBean(termStart, termName, courses));
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
    notifyListeners();
  }

  /// 办公网解绑时清除数据
  void clear() {
    _courses = [];
    _selectedWeek = 1;
    notifyListeners();
  }
}
