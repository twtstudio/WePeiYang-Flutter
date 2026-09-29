import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel;
import 'package:we_pei_yang_flutter/auth/view/info/tju_rebind_dialog.dart';
import 'package:we_pei_yang_flutter/commons/network/classes_service.dart';
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';
import 'package:we_pei_yang_flutter/schedule/network/custom_course_service.dart';
import 'package:we_pei_yang_flutter/schedule/network/schdule_service.dart';

class CourseProvider with ChangeNotifier {
  /// 学校课程
  List<Course> _schoolCourses = [];

  List<Course> get schoolCourses => _schoolCourses;

  /// 自定义课程
  List<Course> _customCourses = [];

  List<Course> get customCourses => _customCourses;

  void addCustomCourse(Course course) {
    _customCourses.add(course);
    saveCustomCourseTable();
  }

  void modifyCustomCourse(Course course, int index) {
    if (_customCourses.length >= index + 1) {
      _customCourses[index] = course;
      saveCustomCourseTable();
    }
  }

  void deleteCustomCourse(int index) {
    if (_customCourses.length >= index + 1) {
      _customCourses.removeAt(index);
      saveCustomCourseTable();
    }
  }

  void saveCustomCourseTable() {
    notifyListeners();
    var time = DateTime.now().millisecondsSinceEpoch;
    // local
    CommonPreferences.courseData.value =
        json.encode(CourseTable(_schoolCourses, _customCourses));
    CommonPreferences.customUpdatedAt.value = time;
    _widgetChannel.invokeMethod("refreshScheduleWidget");
    // remote
    CustomCourseService.postCustomTable(_customCourses, time);
  }

  /// 全部课程
  List<Course> get totalCourses => []
    ..addAll(_customCourses)
    ..addAll(_schoolCourses); // 课表相关一般都用这个

  /// 当前显示的星期
  int _selectedWeek = 1;

  set selectedWeek(int newSelected) {
    if (_selectedWeek == newSelected) return;
    _selectedWeek = newSelected;
    notifyListeners();
  }

  // 同步被实验课Merge之后的课表
  void updateSchoolCourses(List<Course> courses) {
    _schoolCourses = courses;
    notifyListeners();
    _widgetChannel.invokeMethod("refreshScheduleWidget");
    CommonPreferences.courseData.value =
        json.encode(CourseTable(_schoolCourses, _customCourses));
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

  /// 使用后端爬虫（无需填写图形验证码）
  /// [CommonPreferences.useClassesBackend.value]决定了爬虫方式
  ///   --true: 使用后端的完整爬虫接口，直接获取办公网信息
  ///   --false: 仅使用后端ocr接口识别验证码
  /// 若失败则弹出TjuRebindDialog，用户手动填写图形验证码
  void refreshCourseByBackend(BuildContext context) async {
    ToastProvider.running("刷新数据中……");
    try {
      // 後端爬蟲沒了 天天出問題 暫時關閉 一方之後可能要用先這樣臨時處理
      // if (CommonPreferences.useClassesBackend.value && false) {
      //   var data = await ClassesBackendService.getClasses();
      //   if (data == null) throw WpyDioException(error: '云端获取课表失败');
      //   _schoolCourses = data.item1;
      //   notifyListeners();
      //   _widgetChannel.invokeMethod("refreshScheduleWidget");
      await ClassesService.getClasses(context);
    } on DioException catch (_) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) => TjuRebindDialog(),
      );
    }
  }

  /// 使用前端爬虫
  void refreshCourse({
    void Function()? onSuccess,
    void Function(DioException)? onFailure,
  }) {
    ScheduleService.fetchCourses(onResult: (courses) {
      if (courses.isEmpty) {
        // 防止刷出来一个空课表
        return;
      }
      _schoolCourses = courses;
      notifyListeners();
      // 通知小组件更新
      _widgetChannel.invokeMethod("refreshScheduleWidget");
      CommonPreferences.courseData.value =
          json.encode(CourseTable(_schoolCourses, _customCourses));
      onSuccess?.call();
    }, onFailure: (e) {
      onFailure?.call(e);
    });
  }

  void refreshCustomCourse() {
    try {
      CustomCourseService.getToken().then((success) {
        if (!success) return;
        CustomCourseService.getCustomTable().then((courseList) {
          if (courseList == null) {
            // 本地比较新
            var time = CommonPreferences.customUpdatedAt.value;
            CustomCourseService.postCustomTable(_customCourses, time);
          } else {
            // 远程端比较新，[CommonPreferences.customUpdatedAt]已经在[getCustomTable]中更新过了
            _customCourses = courseList;
            notifyListeners();
            CommonPreferences.courseData.value =
                json.encode(CourseTable(_schoolCourses, _customCourses));
            _widgetChannel.invokeMethod("refreshScheduleWidget");
          }
        });
      });
    } catch (e) {
      // TODO：非校内环境
    }
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

  set showExperiment(bool value) {
    CommonPreferences.isShowExperiment.value = value;
    notifyListeners();
  }

  bool get showExperiment => CommonPreferences.isShowExperiment.value;
}
