// @dart = 2.12
import 'dart:convert' show json;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel;
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart'
    show OnFailure;
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/network/schedule_spider.dart';

class CourseProvider with ChangeNotifier {
  /// 所有课程
  List<Course> _courses = [];

  set courses(List<Course> newList) {
    _courses = newList;
    notifyListeners();
  }

  List<Course> get courses => _courses;

  /// 当前显示的星期
  int _selectedWeek = 1;

  set selectedWeek(int newSelected) {
    if (_selectedWeek == newSelected) return;
    _selectedWeek = newSelected;
    notifyListeners();
  }

  int get selectedWeek => _selectedWeek;

  /// 静默重置选中周
  void quietResetWeek() => _selectedWeek = currentWeek;

  // TODO 一学期一共有多少周，暂时写死，之后手动获取
  final int weekCount = 24;

  /// 手动计算当前周，604800代表一周
  int get currentWeek {
    if (isBeforeTermStart) return 1; // 防止week为负数
    var week = ((DateTime.now().millisecondsSinceEpoch / 1000 -
                CommonPreferences.termStart.value) /
            604800)
        .ceil();
    if (week > weekCount) week = weekCount; // 这里要防止越界
    return week;
  }

  final _widgetChannel = MethodChannel('com.twt.service/widget');

  /// 通过爬虫刷新数据，并通知小组件更新
  void refreshCourse({bool hint = false, OnFailure? onFailure}) {
    if (hint) ToastProvider.running("刷新数据中……");
    fetchCourses(onResult: (courses) {
      if (hint) ToastProvider.success("刷新课程表数据成功");
      this.courses = courses; // 这一步会刷新widget
      CommonPreferences.courseData.value =
          json.encode(CourseTable(_courses)); // 刷新本地缓存
      _widgetChannel.invokeMethod("refreshScheduleWidget"); // 刷新课程表widget
    }, onFailure: (e) {
      if (onFailure != null) onFailure(e);
    });
  }

  /// 从缓存中读课表的数据，进入主页之前调用
  void readPref() {
    if (CommonPreferences.courseData.value == '') return;
    CourseTable table =
        CourseTable.fromJson(json.decode(CommonPreferences.courseData.value));
    this.courses = table.courses; // 这一步会刷新widget
  }

  /// 办公网解绑时清除数据
  void clear() {
    this.courses = []; // 这一步会刷新widget
    _selectedWeek = 1;
  }
}

class CourseDisplayProvider with ChangeNotifier {
  /// 课表页星期栏是否收缩
  set shrink(bool value) {
    CommonPreferences.courseAppBarShrink.value = value;
    notifyListeners();
  }

  bool get shrink => CommonPreferences.courseAppBarShrink.value;

  /// 夜猫子模式，这个变量的主要作用是通知widget更新
  set nightMode(bool value) {
    CommonPreferences.nightMode.value = value;
    notifyListeners();
  }

  bool get nightMode => CommonPreferences.nightMode.value;
}
