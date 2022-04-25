// @dart = 2.12
import 'package:we_pei_yang_flutter/commons/network/wpy_dio.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/schedule/model/course.dart';

class CustomCourseDio extends DioAbstract {
  @override
  String baseUrl = 'http://101.42.225.75:8081//';

  @override
  List<InterceptorsWrapper> interceptors = [
    InterceptorsWrapper(onRequest: (options, handler) {
      options.headers['token'] = CommonPreferences.customCourseToken.value;
      return handler.next(options);
    })
  ];
}

final customCourseDio = CustomCourseDio();

class CustomCourseService with AsyncTimer {
  static Future<bool> getToken({bool quiet = true}) async {
    try {
      var response = await customCourseDio
          .post('api/v1/user/auth/fromClient/login', queryParameters: {
        'token': CommonPreferences.token.value,
      });
      CommonPreferences.customCourseToken.value = response.data['data'];
      return true;
    } catch (e) {
      if (!quiet) ToastProvider.error('自定义课表服务加载失败');
      return false;
    }
  }

  static Future<void> updateCustomClass(Course course, int index) async {
    try {
      Map<String, dynamic> map = {
        'index': index,
        'credit': course.credit,
        'class_name': course.name,
        'classDetailList': course.arrangeList
            .map((arrange) => {
                  'class_order': _unitList2Str(arrange.unitList),
                  'classroom': arrange.location,
                  'this_class_teacher': arrange.teacherList.first,
                  'which_week': _weekList2Str(arrange.weekList),
                  'which_weekday': _weekDay2Str(arrange.weekday)
                })
            .toList()
      };
      await customCourseDio.post('customClassTable/update',
          queryParameters: map);
    } catch (e) {
      // ToastProvider.error('更新自定义课程失败');
    }
  }

  static Future<void> deleteCustomClass(int index) async {
    try {
      await customCourseDio.post('customClassTable/deleteClass',
          queryParameters: {'index': index});
    } catch (e) {
      // ToastProvider.error('删除自定义课程失败');
    }
  }

  static Future<void> addCustomClass(Course course, int index) async {
    try {
      Map<String, dynamic> map = {
        'index': index,
        'credit': course.credit,
        'class_name': course.name,
        'classDetailList': course.arrangeList
            .map((arrange) => {
                  'class_order': _unitList2Str(arrange.unitList),
                  'classroom': arrange.location,
                  'this_class_teacher': arrange.teacherList.first,
                  'which_week': _weekList2Str(arrange.weekList),
                  'which_weekday': _weekDay2Str(arrange.weekday)
                })
            .toList()
      };
      await customCourseDio.post('customClassTable/addCustomClass',
          queryParameters: map);
    } catch (e) {
      // ToastProvider.error('添加自定义课程失败');
    }
  }

  static Future<List<Course>?> getCustomTable() async {
    try {
      var response =
          await customCourseDio.get('customClassTable/getCustomTable');
      var courseList = <Course>[];
      for (Map<String, dynamic> courseJson in response.data['data']
          ['customClassTable']) {
        var name = courseJson['class_name'];
        var credit = courseJson['credit'];
        var minWeek = 100, maxWeek = 0;
        var teacherList = <String>[];
        var arrangeList = <Arrange>[];
        for (Map<String, dynamic> arrangeJson
            in courseJson['classDetailList']) {
          var weekList = _weekStr2List(arrangeJson['which_week']);
          if (minWeek > weekList.first) minWeek = weekList.first;
          if (maxWeek < weekList.last) maxWeek = weekList.last;

          var unitList = _unitStr2List(arrangeJson['class_order']);

          var teacherStr = arrangeJson['this_class_teacher'];
          if (!teacherList.contains(teacherStr)) {
            teacherList.add(teacherStr);
          }
          var arrange = Arrange.empty()
            ..location = arrangeJson['classroom']
            ..weekday = _str2WeekDay(arrangeJson['which_weekday'])
            ..weekList = weekList
            ..unitList = unitList
            ..teacherList = [teacherStr];
          arrangeList.add(arrange);
        }
        var weeks = '$minWeek-$maxWeek';
        courseList
            .add(Course.custom(name, credit, weeks, teacherList, arrangeList));
      }
    } catch (e) {
      return null;
    }
  }

  static Future<Course?> getClassBySerial(String serial) async {
    try {
      var response = await customCourseDio.get('customClassTable/${serial}');
      var data = response.data['data'];
      var name = data['class_name'];
      var credit = data['credit'];
      var weeks = data['total_start_end_week'];
      var teacherList = [data['all_teacher'].toString()];
      var arrangeList = <Arrange>[];
      for (Map<String, dynamic> json in data['detailList']) {
        var arrange = Arrange.empty()
          ..location = json['classroom']
          ..weekday = _str2WeekDay(json['which_weekday'])
          ..weekList = _weekStr2List(json['which_week'])
          ..unitList = _unitStr2List(json['class_order'])
          ..teacherList = [json['this_class_teacher']];
        arrangeList.add(arrange);
      }
      return Course.custom(name, credit, weeks, teacherList, arrangeList);
    } catch (e) {
      ToastProvider.error('导入课程失败，请重试');
      return null;
    }
  }
}

// 几种格式：
// 11
// [1-5]
// [11-13]单
// [10-14]双
List<int> _weekStr2List(String str) {
  if (!str.contains('[')) return [int.parse(str)];
  int step = 1;
  if (str.contains('单') || str.contains('双')) step += 1;
  List<String> startEnd = str.substring(1, str.length - step).split('-');
  var result = <int>[];
  for (int i = int.parse(startEnd[0]); i <= int.parse(startEnd[1]); i += step) {
    result.add(i);
  }
  return result;
}

String _weekList2Str(List<int> list) {
  if (list.length == 1) return list.first.toString();
  bool hasOdd = list.any((e) => e.isOdd);
  bool hasEven = list.any((e) => e.isEven);
  var suffix = '';
  if (hasOdd && !hasEven) suffix = '单';
  if (hasEven && !hasOdd) suffix = '双';
  return '[${list.first}-${list.last}]$suffix';
}

List<int> _unitStr2List(String str) =>
    [int.parse(str.split('-')[0]), int.parse(str.split('-')[1])];

String _unitList2Str(List<int> list) => '${list.first}-${list.last}';

int _str2WeekDay(String weekDayStr) => _weekDays.indexOf(weekDayStr);

String _weekDay2Str(int weekDay) => _weekDays[weekDay];

const _weekDays = [
  '',
  '星期一',
  '星期二',
  '星期三',
  '星期四',
  '星期五',
  '星期六',
  '星期日',
];
