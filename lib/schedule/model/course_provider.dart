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
import 'package:we_pei_yang_flutter/schedule/network/custom_course_service.dart';
import 'package:we_pei_yang_flutter/schedule/network/schedule_spider.dart';

class CourseProvider with ChangeNotifier {
  /// 学校课程
  List<Course> _schoolCourses = [];

  List<Course> get schoolCourses => _schoolCourses; // 用于统计学时

  /// 自定义课程
  List<Course> _customCourses = [];

  List<Course> get customCourses => _customCourses; // 用于自定义课程编辑页

  void addCustomCourse(Course course) {
    CustomCourseService.addCustomClass(course, _customCourses.length);
    _customCourses.add(course);
    notifyListeners();
    saveCustomCourse();
  }

  void modifyCustomCourse(Course course, int index) {
    if (_customCourses.length >= index + 1) {
      CustomCourseService.updateCustomClass(course, index);
      _customCourses[index] = course;
      notifyListeners();
      saveCustomCourse();
    }
  }

  void deleteCustomCourse(int index) {
    if (_customCourses.length >= index + 1) {
      CustomCourseService.deleteCustomClass(index);
      _customCourses.removeAt(index);
      notifyListeners();
      saveCustomCourse();
    }
  }

  void saveCustomCourse() {
    CommonPreferences.courseData.value =
        json.encode(CourseTable(_schoolCourses, _customCourses));
    _widgetChannel.invokeMethod("refreshScheduleWidget");
  }

  /// 全部课程
  List<Course> get totalCourses =>
      []..addAll(_customCourses)..addAll(_schoolCourses); // 课表相关一般都用这个

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
      _schoolCourses = courses;
      notifyListeners();
      CommonPreferences.courseData.value =
          json.encode(CourseTable(_schoolCourses, _customCourses));
      _widgetChannel.invokeMethod("refreshScheduleWidget");
    }, onFailure: (e) {
      if (onFailure != null) onFailure(e);
    });

    refreshCustomCourse();
  }

  void refreshCustomCourse() {
    /// 如果本地有缓存就覆盖远程，否则从远程获取
    CustomCourseService.getToken().then((success) {
      if (!success) return;
      if (_customCourses.isNotEmpty) {
        for (int i = 0; i < _customCourses.length; i++) {
          CustomCourseService.updateCustomClass(_customCourses[i], i);
        }
      } else {
        CustomCourseService.getCustomTable().then((courseList) {
          if (courseList == null) return;
          _customCourses = courseList;
          CommonPreferences.courseData.value =
              json.encode(CourseTable(_schoolCourses, _customCourses));
          _widgetChannel.invokeMethod("refreshScheduleWidget");
        });
      }
    });
  }

  /// 从缓存中读课表的数据，进入主页之前调用
  void readPref() {
    if (CommonPreferences.courseData.value == '') return;
    CourseTable table =
        CourseTable.fromJson(json.decode(CommonPreferences.courseData.value));
    _schoolCourses = table.schoolCourses;
    _customCourses = table.customCourses;
    notifyListeners();
  }

  /// 办公网解绑时清除数据
  void clear() {
    _schoolCourses = [];
    _selectedWeek = 1;
    notifyListeners();
  }
}

class CourseDisplayProvider with ChangeNotifier {
  /// 课表页星期栏是否收缩
  set shrink(bool value) {
    CommonPreferences.courseAppBarShrink.value = value;
    notifyListeners();
  }

  bool get shrink => CommonPreferences.courseAppBarShrink.value;

  /// 夜猫子模式
  set nightMode(bool value) {
    CommonPreferences.nightMode.value = value;
    notifyListeners();
  }

  bool get nightMode => CommonPreferences.nightMode.value;
}